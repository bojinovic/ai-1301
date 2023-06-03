// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

import "./Types.sol";
import "./GameManager.sol";
import "./interfaces/IGameLogic.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract GameLogic is IGameLogic, VRFV2WrapperConsumerBase {

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
    address public _sxt;

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

    constructor()        
        VRFV2WrapperConsumerBase(
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693
        )  {
        manager = address(new GameManager(address(this)));
        logic = address(this);
    }

    /// @notice Sets the address of the Space and Time (SxT) Function Consumer
    /// @dev This Function consumer should implement IChainlinkFunctionConsumer interface
    /// @param sxt Address of the deployed SxT Function Consumer
    function setSxT(
        address sxt
    ) public {
        _sxt = sxt;
    }

    /// @notice Creates a new match and registers the corresponding Function Consumers
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param team1_commitmentChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param team1_revealChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function createMatch(
        address team1_commitmentChainlinkFunctionConsumer, 
        address team1_revealChainlinkFunctionConsumer
    ) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("createMatch(address,address)", team1_commitmentChainlinkFunctionConsumer, team1_revealChainlinkFunctionConsumer));

        require(success, "ERR: createMatch Delegate call failed!");
    }

    /// @notice Joins an already existing Match
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param matchId ID of the Match the User wants to join
    /// @param team2_commitmentChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param team2_revealChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function joinMatch(
        uint matchId,
        address team2_commitmentChainlinkFunctionConsumer, 
        address team2_revealChainlinkFunctionConsumer
    ) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("joinMatch(uint256,address,address)", matchId, team2_commitmentChainlinkFunctionConsumer, team2_revealChainlinkFunctionConsumer));

        require(success, "ERR: joinMatch Delegate call failed!");
    }


    function testRequestRandom () public {
        requestRandomness(100000, 3, 1);
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
    /// @param matchId ID of the Match    function commitmentTick(uint matchId) public {
    function commitmentTick(uint matchId) public {
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("commitmentTick(uint256)", matchId));

        require(success, "ERR: commitmentTick Delegate call failed!");
    }

    /// @notice Ends the Commitment Stage and copies the underlying data
    /// @dev Request for both Commitments has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateCommitmentInfo(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("updateCommitmentInfo(uint256)", matchId));

        require(success, "ERR: updateCommitmentInfo Delegate call failed!");
    }

    /// @notice Initiates the start of Reveal Stage
    /// @dev Calls Reveal Function Consumers for both teams
    /// @param matchId ID of the Match
    function revealTick(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("revealTick(uint256)", matchId));

        require(success, "ERR: revealTick Delegate call failed!");
    }

    /// @notice Ends the Reveal Stage and copies the underlying data
    /// @dev Request for both Reveal has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateRevealInfo(uint matchId) public {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("updateRevealInfo(uint256)", matchId));

        require(success, "ERR: updateRevealInfo Delegate call failed!");
    }

    /// @notice Initiates the start of State Update Stage
    /// @dev Calls SxT Function Consumer
    /// @param matchId ID of the Match
    function stateUpdateTick(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("stateUpdateTick(uint256)", matchId));

        require(success, "ERR: stateUpdateTick Delegate call failed!");
    }

    /// @notice Ends the State Update Stage and unpacks the received data
    /// @dev Request for State Update has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateStateUpdateInfo(uint matchId) public {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("updateStateUpdateInfo(uint256)", matchId));

        require(success, "ERR: updateStateUpdateInfo Delegate call failed!");
    }

    /// @notice On-chain execution of the State transition
    /// @dev Used when there's no reporting by SxT because costs a hell of gas :)
    /// @param matchId ID of the Match
    function stateUpdate(uint matchId) public {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("stateUpdate(uint256)", matchId));

        require(success, "ERR: stateUpdate Delegate call failed!");
    }

    /// @notice Checks whether the reported State is correct
    /// @dev If the dispute is justified and there's a discrepancy the game is completly halted
    /// @param matchId ID of the Match
    /// @param stateId ID of the State after which there's a discrepancy
    function dispute(uint matchId, uint stateId) public {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("dispute(uint256,uint256)", matchId, stateId));

        require(success, "ERR: dispute Delegate call failed!");
    }

    /// @notice Generates the next Match State and all of the States in between
    /// @dev Used by .stateUpdate and .dispute
    /// @param matchId ID of the Match
    /// @param stateId ID of the previous State
    /// @return progression A series of intermediate (and final) states
    function getProgression(
        uint matchId,
        uint stateId
    ) public view returns (
        Types.ProgressionState[] memory progression
    ){
        bool shortCircuit = false; //stateShouldBeSkipped[matchId][stateId];

        Types.TeamState[] storage s_initialTeamState = teamState[matchId][stateId];
        Types.TeamState[] memory finalTeamState = teamState[matchId][stateId+1];
        Types.TeamState[] memory initialTeamState = s_initialTeamState;
        
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            initialTeamState[teamId].playerStats = new Types.PlayerStats[](NUMBER_OF_PLAYERS_PER_TEAM);

            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                initialTeamState[teamId].playerStats[playerId] = s_initialTeamState[teamId].playerStats[playerId];
                initialTeamState[teamId].xPos[playerId] = s_initialTeamState[teamId].xPos[playerId];
                initialTeamState[teamId].yPos[playerId] = s_initialTeamState[teamId].yPos[playerId];
            }
        }

        Types.TeamMove[] storage s_currTeamMove = teamMove[matchId][stateId];
        Types.TeamMove[] memory currTeamMove = s_currTeamMove;
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                currTeamMove[teamId].xPos[playerId] = s_currTeamMove[teamId].xPos[playerId];
                currTeamMove[teamId].yPos[playerId] = s_currTeamMove[teamId].yPos[playerId];
            }
        }

        progression = new Types.ProgressionState[](
            TOTAL_PROGRESSION_STEPS
        );

        uint stepId = 0;
        for(; stepId < TOTAL_PROGRESSION_STEPS; ++stepId){

            Types.ProgressionState memory currProgressionState = progression[stepId];
            
            currProgressionState.teamState = new Types.TeamState[](NUMBER_OF_TEAMS);
            for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                Types.TeamState memory currTeamState = currProgressionState.teamState[teamId];
                currTeamState.playerStats = new Types.PlayerStats[](NUMBER_OF_PLAYERS_PER_TEAM);
                currTeamState.xPos = new uint[](NUMBER_OF_PLAYERS_PER_TEAM);
                currTeamState.yPos = new uint[](NUMBER_OF_PLAYERS_PER_TEAM);
            }

            if(stepId == 0){
                currProgressionState.teamState = initialTeamState;
                currProgressionState.teamIdWithTheBall = matchState[matchId][stateId].teamIdWithTheBall;
                currProgressionState.playerIdWithTheBall = matchState[matchId][stateId].playerIdWithTheBall;
                currProgressionState.ballXPos = matchState[matchId][stateId].ballXPos;
                currProgressionState.ballYPos = matchState[matchId][stateId].ballYPos;
                // currProgressionState.shotWasTaken = matchState[matchId][stateId].shotWasTaken;
                // currProgressionState.goalWasScored = matchState[matchId][stateId].goalWasScored;
                currProgressionState = _copyBallPositionFromBallHolder(currProgressionState);
                continue;
            }

            Types.ProgressionState memory prevProgressionState = progression[stepId-1];

            currProgressionState.startingTeamIdWithTheBall = prevProgressionState.startingTeamIdWithTheBall;
            currProgressionState.startingPlayerIdWithTheBall = prevProgressionState.startingPlayerIdWithTheBall;
            currProgressionState.teamIdWithTheBall = prevProgressionState.teamIdWithTheBall;
            currProgressionState.playerIdWithTheBall = prevProgressionState.playerIdWithTheBall;
            currProgressionState.ballWasWon = prevProgressionState.ballWasWon;
            currProgressionState.ballWasWonByTeam = prevProgressionState.ballWasWonByTeam;
            currProgressionState.interceptionOccured = prevProgressionState.interceptionOccured;
            currProgressionState.interceptionAchievedByTeam = prevProgressionState.interceptionAchievedByTeam;
            currProgressionState.ballXPos = prevProgressionState.ballXPos;
            currProgressionState.ballYPos = prevProgressionState.ballYPos;

            for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                currProgressionState.teamState[teamId].playerStats = new Types.PlayerStats[](NUMBER_OF_PLAYERS_PER_TEAM);

                for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                    currProgressionState.teamState[teamId].playerStats[playerId] = prevProgressionState.teamState[teamId].playerStats[playerId];
                    currProgressionState.teamState[teamId].xPos[playerId] = prevProgressionState.teamState[teamId].xPos[playerId];
                    currProgressionState.teamState[teamId].yPos[playerId] = prevProgressionState.teamState[teamId].yPos[playerId];
                }
            }

            if(shortCircuit == false){
                if(stepId < PLAYER_STEPS_PER_MOVE){
                    for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                        for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                            currProgressionState = _advancePlayerPosition(
                                initialTeamState,
                                currTeamMove, 
                                teamId, 
                                playerId,
                                prevProgressionState, 
                                currProgressionState, 
                                stepId
                            );
                        }
                    }
                    currProgressionState = _copyBallPositionFromBallHolder(currProgressionState);
                    
                    currProgressionState =_fightForBall(currProgressionState);
                } else if(stepId < PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE) {
                    if( currProgressionState.interceptionOccured == false
                        && currProgressionState.teamIdWithTheBall == progression[0].teamIdWithTheBall){
                        currProgressionState = _advanceBallPassPosition(
                            progression[PLAYER_STEPS_PER_MOVE-1],
                            progression[0].teamIdWithTheBall,
                            currTeamMove,
                            prevProgressionState,
                            currProgressionState,
                            1 + stepId - PLAYER_STEPS_PER_MOVE
                        );
                    }
                }
            }
        }

        Types.ProgressionState memory lastProgressionStateBeforeShoot = progression[progression.length-1-SHOOT_STEPS];
        Types.ProgressionState memory goalKeeperProgressionState = progression[progression.length-2];
        Types.ProgressionState memory finalProgressionState = progression[progression.length-1];

        if(currTeamMove[lastProgressionStateBeforeShoot.teamIdWithTheBall].wantToShoot){
            lastProgressionStateBeforeShoot.shotWasTaken 
                = goalKeeperProgressionState.shotWasTaken
                = finalProgressionState.shotWasTaken
                = true;
            lastProgressionStateBeforeShoot.teamIdOfTheGoalWhereTheShootWasTaken = 1 - lastProgressionStateBeforeShoot.teamIdWithTheBall;

            goalKeeperProgressionState.ballXPos = (lastProgressionStateBeforeShoot.teamIdWithTheBall == 0) ? FIELD_W : 0;
            goalKeeperProgressionState.ballYPos = FIELD_H / 2;

            finalProgressionState.goalWasScored = _shootScores(lastProgressionStateBeforeShoot);
            finalProgressionState.teamIdWithTheBall 
                // = goalKeeperProgressionState.teamIdWithTheBall 
                = 1 - lastProgressionStateBeforeShoot.teamIdWithTheBall;

            if(finalProgressionState.goalWasScored){
                finalProgressionState.ballXPos = FIELD_W / 2;
                finalProgressionState.ballYPos = FIELD_H / 2;
                finalProgressionState.playerIdWithTheBall = 2;
            } else {
                uint receivingPlayerId = 5;
                finalProgressionState.ballXPos = 
                    finalProgressionState.teamState[1 - lastProgressionStateBeforeShoot.teamIdWithTheBall]
                    .xPos[receivingPlayerId];
                finalProgressionState.ballYPos = 
                    finalProgressionState.teamState[1 - lastProgressionStateBeforeShoot.teamIdWithTheBall]
                    .yPos[receivingPlayerId];
                finalProgressionState.playerIdWithTheBall = receivingPlayerId;
            }
        }
    }

    /// @notice Internal method that Advances the Player's position for one step
    /// @param initialTeamState Inital State from which the Player will be moving
    /// @param wantedMove Where the Player 'wants' to move to
    /// @param teamId ID of the team the Player belongs to
    /// @param playerId Player's ID
    /// @param prevState From Where the Player is Moving
    /// @param nextState Where the Player  will end up
    /// @param stepId ID of the current Progression Step
    /// @return Updated State
    function _advancePlayerPosition(
        Types.TeamState[] memory initialTeamState,
        Types.TeamMove[] memory wantedMove,
        uint teamId,
        uint playerId,
        Types.ProgressionState memory prevState,
        Types.ProgressionState memory nextState,
        uint stepId
    ) internal view returns (Types.ProgressionState memory) {

        uint[2] memory wantedPos = [ 
            wantedMove[teamId].xPos[playerId], 
            wantedMove[teamId].yPos[playerId] 
        ];

        uint[2] memory initialPos = [
            initialTeamState[teamId].xPos[playerId],
            initialTeamState[teamId].yPos[playerId]
        ];

        uint[2] memory currPos = [
            prevState.teamState[teamId].xPos[playerId],
            prevState.teamState[teamId].yPos[playerId]
        ];


        if(currPos[0] == wantedPos[0] && currPos[1] == currPos[1]){
            return nextState;
        }

        int[2] memory diff = [
            int(wantedPos[0]) - int(initialPos[0]),
            int(wantedPos[1]) - int(initialPos[1])
        ];

        uint distance = uint(diff[0]*diff[0] + diff[1]*diff[1]);

        Types.PlayerStats memory currPlayerStats = 
            prevState.teamState[teamId].playerStats[playerId];

        if(true
            // currPlayerStats.stamina >= STAMINA_LOSS_PER_STEP
            //&& currPlayerStats.speed * PLAYER_STEPS_PER_MOVE >= distance
        ){
            uint[2] memory newPos = [
                diff[0] > 0 ? 
                    (currPos[0] + (wantedPos[0] - initialPos[0]) / PLAYER_STEPS_PER_MOVE)
                    :(currPos[0] - (initialPos[0] - wantedPos[0]) / PLAYER_STEPS_PER_MOVE),
                diff[1] > 0 ? 
                    (currPos[1] + (wantedPos[1] - initialPos[1]) / PLAYER_STEPS_PER_MOVE)
                    :(currPos[1] - (initialPos[1] - wantedPos[1]) / PLAYER_STEPS_PER_MOVE)
            ];

            if(stepId == PLAYER_STEPS_PER_MOVE){
                newPos[0] = wantedPos[0];
                newPos[1] = wantedPos[1];
            }

            if(newPos[0] < FIELD_W && newPos[1] < FIELD_H){
                //player can move
                nextState.teamState[teamId].xPos[playerId] = newPos[0];
                nextState.teamState[teamId].yPos[playerId] = newPos[1];
                nextState.teamState[teamId].playerStats[playerId].stamina = 
                    (nextState.teamState[teamId].playerStats[playerId].stamina > STAMINA_LOSS_PER_STEP) ?
                    nextState.teamState[teamId].playerStats[playerId].stamina - STAMINA_LOSS_PER_STEP:
                    STAMINA_LOSS_PER_STEP;
                // console.log("newPos: %s %s", newPos[0], newPos[1]);
            }
        }

        return nextState;
    }

    /// @notice Internal method that Advances the Ball's position while it's being passed
    /// @param initialState Inital State from which the Player will be moving
    /// @param wantedMove Where the Player 'wants' to move to
    /// @param teamId ID of the team the Player belongs to
    /// @param prevState From Where the Player is Moving
    /// @param nextState Where the Player  will end up
    /// @param stepId ID of the current Progression Step
    /// @return Updated State
    function _advanceBallPassPosition(
        Types.ProgressionState memory initialState,
        uint teamId,
        Types.TeamMove[] memory wantedMove,
        Types.ProgressionState memory prevState,
        Types.ProgressionState memory nextState,
        uint stepId
    ) internal view returns (
        Types.ProgressionState memory
    ) {

        uint[2] memory wantedPos = [ 
            initialState.teamState[teamId].xPos[wantedMove[teamId].receivingPlayerId], 
            initialState.teamState[teamId].yPos[wantedMove[teamId].receivingPlayerId]
        ];

        uint[2] memory initialPos = [
            initialState.ballXPos,
            initialState.ballYPos
        ];

        uint[2] memory currPos = [
            prevState.ballXPos,
            prevState.ballYPos
        ];

        if(currPos[0] == wantedPos[0] && currPos[1] == currPos[1]){
            nextState.ballXPos = wantedPos[0];
            nextState.ballYPos = wantedPos[1];
            return nextState;
        }

        int[2] memory diff = [
            int(wantedPos[0]) - int(initialPos[0]),
            int(wantedPos[1]) - int(initialPos[1])
        ];

        uint[2] memory newPos = [
            diff[0] > 0 ? 
                (currPos[0] + (wantedPos[0] - initialPos[0]) / BALL_STEPS_PER_MOVE)
                :(currPos[0] - (initialPos[0] - wantedPos[0]) / BALL_STEPS_PER_MOVE),
            diff[1] > 0 ? 
                (currPos[1] + (wantedPos[1] - initialPos[1]) / BALL_STEPS_PER_MOVE)
                :(currPos[1] - (initialPos[1] - wantedPos[1]) / BALL_STEPS_PER_MOVE)
        ];


        if(stepId == BALL_STEPS_PER_MOVE){
            newPos[0] = wantedPos[0];
            newPos[1] = wantedPos[1];
        }

        if(newPos[0] < FIELD_W && newPos[1] < FIELD_H){
            nextState.ballXPos = newPos[0];
            nextState.ballYPos = newPos[1];
        }

        return _checkForInterceptions(initialState, teamId, wantedMove, prevState, nextState, stepId);
    }

    function _checkForInterceptions (
        Types.ProgressionState memory initialState,
        uint teamId,
        Types.TeamMove[] memory wantedMove,
        Types.ProgressionState memory prevState,
        Types.ProgressionState memory nextState,
        uint stepId
    ) internal view returns (
        Types.ProgressionState memory
    ) {
        uint oposingTeamId = 1 - initialState.teamIdWithTheBall;
        for(uint oposingPlayerId = 0; oposingPlayerId < NUMBER_OF_PLAYERS_PER_TEAM; ++oposingPlayerId){
            
            if(
                _sqrDistanceBetweenBallAndPlayer(
                    nextState,
                    oposingTeamId, 
                    oposingPlayerId
                ) < MAX_BALL_DISTANCE_REQUIRED
            ) {
                (uint winningTeamId, uint winningPlayerId) =_whoWinsTheDuel(
                    initialState,
                    initialState.teamIdWithTheBall,
                    initialState.startingPlayerIdWithTheBall,
                    oposingTeamId,
                    oposingPlayerId
                );
                if(winningTeamId != initialState.teamIdWithTheBall) {
                    //ball has been intecepted
                    nextState.interceptionOccured = true;
                    nextState.interceptionAchievedByTeam = oposingTeamId;
                    nextState.teamIdWithTheBall = winningTeamId;
                    nextState.playerIdWithTheBall = winningPlayerId;
                    nextState.startingTeamIdWithTheBall = teamId;
                    nextState.startingPlayerIdWithTheBall = initialState.startingPlayerIdWithTheBall;
                    // console.log("INTERCEPTION OCCURED %s", stepId);
                    // require(false, "YEAH MOFO");
                    break;
                }
            }
        }

        if(nextState.interceptionOccured == false){
            nextState.teamIdWithTheBall = teamId;
            nextState.playerIdWithTheBall = wantedMove[teamId].receivingPlayerId;
            nextState.startingTeamIdWithTheBall = teamId;
        }

        return nextState;
    }

    /// @notice Internal method that Copies the Ball's position from the Player that has it
    /// @param currState Current State
    /// @return Updated State
    function _copyBallPositionFromBallHolder(
        Types.ProgressionState memory currState
    ) internal view returns (
        Types.ProgressionState memory
    ) {

        Types.TeamState memory tState = currState.teamState[currState.teamIdWithTheBall];

        currState.ballXPos = tState.xPos[currState.playerIdWithTheBall];
        currState.ballYPos = tState.yPos[currState.playerIdWithTheBall];

        return currState;
    }

    /// @notice Internal method that determines who wins the ball in duels
    /// @param currState Current State
    /// @return Updated State
    function _fightForBall(
        Types.ProgressionState memory currState
    ) internal view returns (
        Types.ProgressionState memory
    ) {
        uint teamId = currState.teamIdWithTheBall;
        uint startingPlayerIdWithTheBall = currState.playerIdWithTheBall;

        uint oposingTeamId = 1 - teamId;


        for(uint oposingPlayerId = 0; oposingPlayerId < NUMBER_OF_PLAYERS_PER_TEAM; ++oposingPlayerId){
            if(
                _sqrDistanceBetweenPlayers(
                    currState,
                    teamId,
                    startingPlayerIdWithTheBall, 
                    oposingTeamId, 
                    oposingPlayerId
                ) < MAX_BALL_DISTANCE_REQUIRED
            ) {
                (uint winningTeamId, uint winningPlayerId) =_whoWinsTheDuel(
                    currState,
                    currState.teamIdWithTheBall,
                    startingPlayerIdWithTheBall,
                    oposingTeamId,
                    oposingPlayerId
                );
                if(winningTeamId != currState.teamIdWithTheBall) {
                    //ball has been won
                    currState.ballWasWon = true;
                    currState.ballWasWonByTeam = oposingTeamId;
                    currState.playerIdWithTheBall = winningPlayerId;
                    currState.startingTeamIdWithTheBall = teamId;
                    currState.startingPlayerIdWithTheBall = startingPlayerIdWithTheBall;
                    break;
                }
            }
        }

        return currState;
    }
    /// @notice Internal method that determines the squared distance between a player and a ball
    /// @param currState Current State
    /// @param oposingTeamId Player's Team ID
    /// @param oposingPlayerId Player's ID
    /// @return distance (squared)
    function _sqrDistanceBetweenBallAndPlayer(
        Types.ProgressionState memory currState,
        uint oposingTeamId,
        uint oposingPlayerId
    ) internal view returns (
        uint distance
    ) {
        Types.TeamState memory tState = currState.teamState[oposingTeamId];
        
        uint xDist = 
            currState.ballXPos > tState.xPos[oposingPlayerId] ?
            currState.ballXPos - tState.xPos[oposingPlayerId] :
            tState.xPos[oposingPlayerId] - currState.ballXPos ;

        uint yDist = 
            currState.ballYPos > tState.yPos[oposingPlayerId] ?
            currState.ballYPos - tState.yPos[oposingPlayerId] :
            tState.yPos[oposingPlayerId] - currState.ballYPos ;

        distance = xDist ** 2 + yDist ** 2;
    }
    /// @notice Internal method that determines the squared distance between a player and a ball
    /// @param currState Current State
    /// @param teamId Player's Team ID
    /// @param playerId Player's ID
    /// @param oposingTeamId Opossing Player's Team ID
    /// @param oposingPlayerId Opossing Player's ID
    /// @return distance (squared)
    function _sqrDistanceBetweenPlayers(
        Types.ProgressionState memory currState,
        uint teamId,
        uint playerId,
        uint oposingTeamId,
        uint oposingPlayerId
    ) internal view returns (
        uint distance
    ) {

        Types.TeamState memory tState1 = currState.teamState[teamId];
        Types.TeamState memory tState2 = currState.teamState[oposingTeamId];
        
        uint xDist = 
            tState1.xPos[playerId] > tState2.xPos[oposingPlayerId] ?
            tState1.xPos[playerId] - tState2.xPos[oposingPlayerId] :
            tState2.xPos[oposingPlayerId] - tState1.xPos[playerId] ;

        uint yDist = 
            tState1.yPos[playerId] > tState2.yPos[oposingPlayerId] ?
            tState1.yPos[playerId] - tState2.yPos[oposingPlayerId] :
            tState2.yPos[oposingPlayerId] - tState1.yPos[playerId] ;

        distance = xDist ** 2 + yDist ** 2;
    }

    /// @notice Internal method that determines who wins a duel
    /// @param currState Current State
    /// @param teamId Player's Team ID
    /// @param playerId Player's ID
    /// @param oposingTeamId Opossing Player's Team ID
    /// @param oposingPlayerId Opossing Player's ID
    /// @return winningTeamId ID of the Winning Team 
    /// @return winningPlayerId ID of the Winning Player 
    function _whoWinsTheDuel(
        Types.ProgressionState memory currState,
        uint teamId,
        uint playerId,
        uint oposingTeamId,
        uint oposingPlayerId
    ) internal view returns (
        uint winningTeamId,
        uint winningPlayerId
    ) {
        uint totalSkill = 
            currState.teamState[teamId].playerStats[playerId].skill
            + currState.teamState[teamId].playerStats[playerId].skill + 1;

        uint rnd = _getCurrSeed();
        if(currState.teamState[teamId].playerStats[playerId].skill < (rnd % totalSkill)){
            winningTeamId = teamId;
            winningPlayerId = playerId;
        } else {
            winningTeamId = oposingTeamId;
            winningPlayerId = oposingPlayerId;
        }
    }
    /// @notice Internal method that determines if a shoot leads to a goal
    /// @param currState Current State
    /// @return scored Goal or no Goal
    function _shootScores(
        Types.ProgressionState memory currState
    ) internal view returns (
        bool scored
    ) {
        uint playerSkill = currState.teamState[currState.teamIdWithTheBall]
                                    .playerStats[currState.playerIdWithTheBall]
                                    .skill;

        uint goalKeeperSkill = currState.teamState[1-currState.teamIdWithTheBall]
                                    .goalKeeperStats
                                    .skill;

         uint totalSkill = playerSkill + goalKeeperSkill;

        uint rnd = _getCurrSeed();
        return true;
        if(playerSkill < (rnd % totalSkill)){
            return true;
        } else {
            return false;
        }
    }

    function _getCurrSeed() internal view returns (uint) {
        return 1301;
    }


}
