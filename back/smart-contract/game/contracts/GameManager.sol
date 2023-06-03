// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

import "./Types.sol";
import "./interfaces/IGameLogic.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract GameManager is VRFV2WrapperConsumerBase {

    uint constant public NUMBER_OF_TEAMS = 2;
    uint constant public NUMBER_OF_PLAYERS_PER_TEAM = 10;

    uint constant public STAMINA_REQUIREMENT_FOR_ADVANCEMENT = 10;
    uint constant public PLAYER_STEPS_PER_MOVE = 5;
    uint constant public BALL_STEPS_PER_MOVE = 7;
    uint constant public SHOOT_STEPS = 2;

    uint constant public TOTAL_PROGRESSION_STEPS = PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE + SHOOT_STEPS;

    uint constant public BITS_PER_PLAYER_X_POS = 10;
    uint constant public BITS_PER_PLAYER_Y_POS = 9;

    uint constant public MAX_BALL_DISTANCE_REQUIRED = 25;

    uint constant public FIELD_W = 2 ** BITS_PER_PLAYER_X_POS;
    uint constant public FIELD_H = 2 ** BITS_PER_PLAYER_Y_POS;

    uint constant public STAMINA_LOSS_PER_STEP = 2;

    bool public gameIsHalted = false;

    address public logic;
    address public ticker;
    address public sxt;

    uint public matchCounter;

    mapping(uint => Types.MatchInfo) public matchInfo;
    mapping(uint => uint) public seedRequestIdMatchId;
    mapping(uint => uint) public matchIdToMatchStateId;
    mapping(uint => mapping(uint => Types.MatchState)) matchState;
    mapping(uint => mapping(uint => Types.TeamState[])) teamState;
    mapping(uint => mapping(uint => Types.TeamMove[])) public teamMove;
    mapping(uint => mapping(uint => bool)) public stateShouldBeSkipped;

    address public manager;

    event MatchEnteredStage(uint matchId, Types.MATCH_STAGE stage);
    constructor(address _logic) 
        VRFV2WrapperConsumerBase(
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693
        ) {
        logic = _logic;
    }

    /// @notice Creates a new match and registers the corresponding Function Consumers
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param commitmentFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param revealFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function createMatch(
        address commitmentFunctionConsumer, 
        address revealFunctionConsumer
    ) public {

        uint matchId = matchCounter;

        _initStorageForMatch(matchId, 0);
        _setPlayersToInitialPositions(matchId, 0);

        Types.MatchInfo storage currMatch = matchInfo[matchId];

        currMatch.stage = Types.MATCH_STAGE.P1_CREATED_THE_MATCH;
        currMatch.commitmentFunctionConsumer[0] = commitmentFunctionConsumer;
        currMatch.revealFunctionConsumer[0] = revealFunctionConsumer;

        matchCounter += 1;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }
    /// @notice Joins an already existing Match
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param matchId ID of the Match the User wants to join
    /// @param commitmentFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param revealFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function joinMatch(
        uint matchId,
        address commitmentFunctionConsumer, 
        address revealFunctionConsumer
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.P1_CREATED_THE_MATCH, 
            "ERR: You can only join a newly created match!"
        );

        currMatch.commitmentFunctionConsumer[1] = commitmentFunctionConsumer;
        currMatch.revealFunctionConsumer[1] = revealFunctionConsumer;

        currMatch.stage = Types.MATCH_STAGE.P2_JOINED_THE_MATCH;

        emit MatchEnteredStage(matchId, currMatch.stage);

        _requestSeed(matchId);
    }

    function _requestSeed(
        uint matchId
    ) internal {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        uint requestId = requestRandomness(300000, 3, 1);

        seedRequestIdMatchId[requestId] = matchId;

        currMatch.stage = Types.MATCH_STAGE.RANDOM_SEED_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }


    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        uint matchId = seedRequestIdMatchId[_requestId];

        Types.MatchInfo storage currMatch = matchInfo[matchId];

        currMatch.seed = _randomWords[0];

        currMatch.stage = Types.MATCH_STAGE.RANDOM_SEED_RECEIVED;

        emit MatchEnteredStage(seedRequestIdMatchId[_requestId], currMatch.stage);
    }

    /// @notice Initiates the start of Commitment Stage
    /// @dev Calls Commitment Function Consumers for both teams
    /// @param matchId ID of the Match
    function commitmentTick(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_RECEIVED 
            || currMatch.stage == Types.MATCH_STAGE.STATE_UPDATE_PERFORMED, 
            "ERR: Match not in correct stage to fetch Commitments!"
        );

        if(currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_RECEIVED){
            _createPlayerStats(matchId);
        }

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).requestData();
        }

        currMatch.stage = Types.MATCH_STAGE.COMMITMENTS_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    /// @notice Ends the Commitment Stage and copies the underlying data
    /// @dev Request for both Commitments has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateCommitmentInfo(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.COMMITMENTS_FETCHED,
            "ERR: Match not in correct stage to receive Commitments!"
        );        
        
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            require(
                IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).dataIsReady(),
                "ERR: Not all teams have issued commitments!"
            );
        }

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            _updateTeamMoveCommitments(
                matchId, 
                teamId,
                IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).copyData()
            );      
        }

        currMatch.stage = Types.MATCH_STAGE.COMMITMENTS_RECEIVED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    function _updateTeamMoveCommitments(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {
        Types.TeamMove storage currTeamMove = teamMove[matchId][matchIdToMatchStateId[matchId]][teamId];

        currTeamMove.commitment = payload;
    }

    /// @notice Initiates the start of Reveal Stage
    /// @dev Calls Reveal Function Consumers for both teams
    /// @param matchId ID of the Match
    function revealTick(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.COMMITMENTS_RECEIVED,
            "ERR: Match not in correct stage to fetch Reaveals!"
        );

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).requestData();
        }

        currMatch.stage = Types.MATCH_STAGE.REVEALS_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    /// @notice Ends the Reveal Stage and copies the underlying data
    /// @dev Request for both Reveal has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateRevealInfo(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.REVEALS_FETCHED,
            "ERR: Match not in correct stage to receive Reveals!"
        );        
        
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            require(
                IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).dataIsReady(),
                "ERR: Not all teams have issued commitments!"
            );
        }

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            _updateTeamMove(
                matchId, 
                teamId,
                IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).copyData()
            );      
        }

        currMatch.stage = Types.MATCH_STAGE.REVEAL_RECEIVED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    /// @notice Initiates the start of State Update Stage
    /// @dev Calls SxT Function Consumer
    /// @param matchId ID of the Match
    function stateUpdateTick(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.REVEAL_RECEIVED,
            "ERR: Match not in correct stage to fetch State update!"
        );

        IChainlinkFunctionConsumer(sxt).requestData();

        currMatch.stage = Types.MATCH_STAGE.STATE_UPDATE_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    /// @notice Ends the State Update Stage and unpacks the received data
    /// @dev Request for State Update has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateStateUpdateInfo(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        uint stateId = matchIdToMatchStateId[matchId];
        _initStorageForMatch(matchId, stateId+1);

        require(
            currMatch.stage == Types.MATCH_STAGE.STATE_UPDATE_FETCHED,
            "ERR: Match not in correct stage to receive State update!"
        );        
        
        require(
            IChainlinkFunctionConsumer(sxt).dataIsReady(),
            "ERR: State update has not been resolved!"
        );

        _unpackReportedState(
            matchId,
            stateId+1,
            IChainlinkFunctionConsumer(sxt).copyData()
        );

        matchIdToMatchStateId[matchId] += 1;

        currMatch.stage = Types.MATCH_STAGE.STATE_UPDATE_PERFORMED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    /// @notice On-chain execution of the State transition
    /// @dev Used when there's no reporting by SxT because costs a hell of gas :)
    /// @param matchId ID of the Match
    function stateUpdate(uint matchId) public {
        Types.MatchInfo storage s_currMatch = matchInfo[matchId];
        uint stateId = matchIdToMatchStateId[matchId];
        _initStorageForMatch(matchId, stateId+1);
        Types.MatchState storage s_currMatchState = matchState[matchId][stateId+1];

        require(
            s_currMatch.stage == Types.MATCH_STAGE.REVEAL_RECEIVED,
            "ERR: Match not in correct stage to perform a State update!"
        ); 

        Types.ProgressionState[] memory progression = IGameLogic(logic).getProgression(matchId, stateId);

        Types.ProgressionState memory lastProgressionState = progression[progression.length-1];

        Types.TeamState[] memory currTeamState = lastProgressionState.teamState;
        Types.TeamState[] storage s_currTeamState = teamState[matchId][stateId+1];

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){

            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                s_currTeamState[teamId].playerStats[playerId] = currTeamState[teamId].playerStats[playerId];
                s_currTeamState[teamId].xPos[playerId] = currTeamState[teamId].xPos[playerId];
                s_currTeamState[teamId].yPos[playerId] = currTeamState[teamId].yPos[playerId];
            }
        }

        s_currMatchState.teamIdWithTheBall = lastProgressionState.teamIdWithTheBall;
        s_currMatchState.playerIdWithTheBall = lastProgressionState.playerIdWithTheBall;
        s_currMatchState.ballXPos = lastProgressionState.ballXPos;
        s_currMatchState.ballYPos = lastProgressionState.ballYPos;
        s_currMatchState.shotWasTaken = lastProgressionState.shotWasTaken;
        s_currMatchState.goalWasScored = lastProgressionState.goalWasScored;

        if(lastProgressionState.shotWasTaken){
            if(lastProgressionState.goalWasScored){
                 _setPlayersToInitialPositions(matchId, stateId+1);
                s_currMatchState.teamIdWithTheBall = lastProgressionState.teamIdWithTheBall;
                s_currMatchState.playerIdWithTheBall = lastProgressionState.playerIdWithTheBall;
                s_currMatchState.ballXPos = lastProgressionState.ballXPos;
                s_currMatchState.ballYPos = lastProgressionState.ballYPos;
                s_currMatchState.shotWasTaken = lastProgressionState.shotWasTaken;
                s_currMatchState.goalWasScored = lastProgressionState.goalWasScored;
            } else {

            }
        }

        matchIdToMatchStateId[matchId] += 1;

        s_currMatch.stage = Types.MATCH_STAGE.STATE_UPDATE_PERFORMED;

        emit MatchEnteredStage(matchId, s_currMatch.stage);
    }
    
    /// @notice Checks whether the reported State is correct
    /// @dev If the dispute is justified and there's a discrepancy the game is completly halted
    /// @param matchId ID of the Match
    /// @param stateId ID of the State after which there's a discrepancy
    function dispute(
        uint matchId,
        uint stateId
    ) public {

        require(
            stateId < matchIdToMatchStateId[matchId] - 2,
            "ERR: The match has not progressed that far"
        );

        Types.MatchState storage s_actualMatchState = matchState[matchId][stateId+1];

        Types.ProgressionState memory expected = 
            IGameLogic(logic).getProgression(matchId, stateId)[TOTAL_PROGRESSION_STEPS-1];

        gameIsHalted = 
            expected.teamIdWithTheBall != s_actualMatchState.teamIdWithTheBall
            || expected.playerIdWithTheBall != s_actualMatchState.playerIdWithTheBall
            || expected.ballXPos != s_actualMatchState.ballXPos
            || expected.ballYPos != s_actualMatchState.ballYPos
            || expected.shotWasTaken != s_actualMatchState.shotWasTaken
            || expected.goalWasScored != s_actualMatchState.goalWasScored;
    }

    /// @notice Unpacks the SxT reported state
    /// @param matchId ID of the Match
    /// @param stateId ID of the State that will be unpacked
    /// @param payload Received Data Payload
    function _unpackReportedState(
        uint matchId,
        uint stateId,
        bytes memory payload
    ) internal {
        Types.MatchState storage mState = matchState[matchId][stateId];
        mState.reportedState = payload;

        // (uint team1Pos, uint team2Pos, uint meta) =
        //     abi.decode(payload, (uint, uint, uint));


        uint team1Pos =123; uint team2Pos = 123123; uint meta = 123123;

        uint[2] memory teamPos = [team1Pos, team2Pos];

        uint SHIFT_STEP = BITS_PER_PLAYER_X_POS + BITS_PER_PLAYER_Y_POS;

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            Types.TeamState storage tState = teamState[matchId][stateId][teamId];

            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                uint segment = (teamPos[teamId] >> (playerId * SHIFT_STEP));
                tState.xPos[playerId] = (segment >> BITS_PER_PLAYER_Y_POS) & (2**BITS_PER_PLAYER_X_POS - 1);
                tState.yPos[playerId] = segment & (2**BITS_PER_PLAYER_Y_POS - 1);
            }
        }

        mState.teamIdWithTheBall = meta & 1;
        uint proposedPlayerId =  (meta >> 1) & 15;
        mState.playerIdWithTheBall = proposedPlayerId < NUMBER_OF_PLAYERS_PER_TEAM ? proposedPlayerId: 0;

        mState.ballXPos = (meta >> 5) & (2**BITS_PER_PLAYER_X_POS - 1);
        mState.ballYPos = (meta >> (5+BITS_PER_PLAYER_X_POS)) & (2**BITS_PER_PLAYER_Y_POS - 1);

        mState.shotWasTaken = ((meta >> (5+BITS_PER_PLAYER_X_POS+BITS_PER_PLAYER_Y_POS)) & 1) == 1;
        mState.goalWasScored = ((meta >> (5+BITS_PER_PLAYER_X_POS+BITS_PER_PLAYER_Y_POS+1)) & 1) == 1;
    }

    /// @notice Updates the Team move based on received Payload
    /// @param matchId ID of the Match
    /// @param teamId ID of the Team that will be updated
    /// @param payload Received Data Payload
    function _updateTeamMove(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {
        Types.TeamMove storage currTeamMove = teamMove[matchId][matchIdToMatchStateId[matchId]][teamId];

        bytes memory revealHash = abi.encode(keccak256(payload));

        // require(
        //     keccak256(revealHash) == keccak256(currTeamMove.commitment),
        //     "ERR: Reveal doesn't correspond to the Commitment"  
        // );

        currTeamMove.reveal = payload;

        uint seed = 13; uint packedData = 13;
        // (uint seed, uint packedData) = abi.decode(payload, (uint, uint));

        currTeamMove.seed = seed;

        uint SHIFT_STEP = BITS_PER_PLAYER_X_POS + BITS_PER_PLAYER_Y_POS;

        for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
            uint segment = (packedData >> (playerId * SHIFT_STEP));
            currTeamMove.xPos[playerId] = (segment >> BITS_PER_PLAYER_Y_POS) & (2**BITS_PER_PLAYER_X_POS - 1);
            currTeamMove.yPos[playerId] = segment & (2**BITS_PER_PLAYER_Y_POS - 1);
        }

        currTeamMove.wantToShoot = true; //(packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM) & 1) == 1;
        
        currTeamMove.wantToPass = (packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM + 1) & 1) == 1;

        uint potentialReceivingPlayerId = (packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM + 2) & 0xf);
        currTeamMove.receivingPlayerId = potentialReceivingPlayerId < 10 ? potentialReceivingPlayerId : 0;
    }

    /// @notice Sets the player to Start Positions (in storage)
    /// @param matchId ID of the Match
    /// @param stateId ID of the State that will be altered
    function _setPlayersToInitialPositions(
        uint matchId,
        uint stateId
    ) public {
        uint teamId = 0;

        Types.MatchState storage s_currMatchState = matchState[matchId][stateId];
        s_currMatchState.ballXPos = FIELD_W / 2;
        s_currMatchState.ballYPos = FIELD_H / 2;
        Types.TeamState storage currTeamState = teamState[matchId][stateId][teamId];

        for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
            if(playerId == 0){
                currTeamState.xPos[playerId] = FIELD_W/2;
                currTeamState.yPos[playerId] = FIELD_H/2;
            } else if (playerId > 0 && playerId < 4){
                currTeamState.xPos[playerId] = 3 * (FIELD_W/8);
                currTeamState.yPos[playerId] = playerId * (FIELD_H/4);
            }  else if (playerId > 3 && playerId < 8){
                currTeamState.xPos[playerId] = 2 * (FIELD_W/8);
                currTeamState.yPos[playerId] = (playerId-3) * (FIELD_H/5);
            } else if (playerId > 7 && playerId < 10){
                currTeamState.xPos[playerId] = 1 * (FIELD_W/8);
                currTeamState.yPos[playerId] = (playerId-7) * (FIELD_H/3);
            }
        }

        teamId = 1;
        Types.TeamState storage currTeamState2 = teamState[matchId][stateId][teamId];
        for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
            if(playerId == 0){
                currTeamState2.xPos[playerId] = FIELD_W/2;
                currTeamState2.yPos[playerId] = FIELD_H/2;
            } else if (playerId > 0 && playerId < 4){
                currTeamState2.xPos[playerId] = 5 * (FIELD_W/8);
                currTeamState2.yPos[playerId] = playerId * (FIELD_H/4);
            }  else if (playerId > 3 && playerId < 8){
                currTeamState2.xPos[playerId] = 6 * (FIELD_W/8);
                currTeamState2.yPos[playerId] = (playerId-3) * (FIELD_H/5);
            } else if (playerId > 7 && playerId < 10){
                currTeamState2.xPos[playerId] = 7 * (FIELD_W/8);
                currTeamState2.yPos[playerId] = (playerId-7) * (FIELD_H/3);
            }
        }
    }

    /// @notice Sets the initial player stats based on VRF's Seed
    /// @param matchId ID of the Match
    function _createPlayerStats(
        uint matchId
    ) internal { 
        
        uint seed = matchInfo[matchId].seed;
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            Types.TeamState storage tState = teamState[matchId][0][teamId];
            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                uint segment = (seed >> ((1+teamId)*playerId*11));
                tState.playerStats[playerId].speed = segment & (2**7-1);
                tState.playerStats[playerId].skill = (segment >> 7) & (2**7-1);
                tState.playerStats[playerId].stamina = (segment >> 14) & (2**7-1);
            }
            tState.goalKeeperStats.speed = ((seed >> (teamId*21)) >> 0) & (2**7-1);
            tState.goalKeeperStats.skill = ((seed >> (teamId*21)) >> 7) & (2**7-1);
            tState.goalKeeperStats.stamina = ((seed >> (teamId*21)) >> 14) & (2**7-1);
        }
    }

    /// @notice Initializes all the arrays and field for a State
    /// @param matchId ID of the Match
    /// @param currMoveId ID of the MOve which will be instantiated
    function _initStorageForMatch(
        uint matchId, 
        uint currMoveId
    ) public {

        if(currMoveId == 0){
            for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                matchInfo[matchId].commitmentFunctionConsumer.push();
                matchInfo[matchId].revealFunctionConsumer.push();
            }
        }

        Types.MatchState storage currMatchState = matchState[matchId][currMoveId];
        Types.TeamState[] storage currTeamState = teamState[matchId][currMoveId];
        Types.TeamMove[] storage currTeamMove = teamMove[matchId][currMoveId];
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){

            currMatchState.score.push(0);

            currTeamState.push();
            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                currTeamState[teamId].playerStats.push();

                currTeamState[teamId].xPos.push();
                currTeamState[teamId].yPos.push();
            }

            currTeamMove.push();
            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                currTeamMove[teamId].xPos.push();
                currTeamMove[teamId].yPos.push();
            }
        }
    }
}
