// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Types.sol";
import "./GameLogic.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
import "hardhat/console.sol";

contract GameManager {

    uint constant public NUMBER_OF_TEAMS = 2;
    uint constant public NUMBER_OF_PLAYERS_PER_TEAM = 10;

    uint constant public STAMINA_REQUIREMENT_FOR_ADVANCEMENT = 10;
    uint constant public PLAYER_STEPS_PER_MOVE = 5;
    uint constant public BALL_STEPS_PER_MOVE = 7;

    uint constant public BITS_PER_PLAYER_X_POS = 10;
    uint constant public BITS_PER_PLAYER_Y_POS = 9;


    uint constant public MAX_BALL_DISTANCE_REQUIRED = 5;

    uint constant public FIELD_W = 1024;
    uint constant public FIELD_H = 512;

    address public logic;
    address public ticker;

    uint public matchCounter;

    mapping(uint => Types.MatchInfo) public matchInfo;
    mapping(uint => uint) public seedRequestIdMatchId;
    mapping(uint => uint) public matchIdToMatchStateId;
    mapping(uint => mapping(uint => Types.MatchState)) matchState;
    mapping(uint => mapping(uint => Types.TeamState[])) teamState;
    mapping(uint => mapping(uint => Types.TeamMove[])) public teamMove;

    event MatchEnteredStage(uint matchId, Types.MATCH_STAGE stage);
    constructor(address _logic) {
        logic = _logic;
    }

    function _initStorageForMatch(
        uint matchId, 
        uint currMoveId
    ) public {

        console.log('INITIALIZINGF STORAGE FOR STATEID %s', currMoveId);
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

        requestSeed(matchId);

        fullfilSeedRequest(1301, 782491231231231231124151251301);

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    function requestSeed(
        uint matchId
    ) internal {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        //TODO: initiate VRF request...
        seedRequestIdMatchId[1301] = matchId;

        currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    function fullfilSeedRequest(
        uint requestId,
        uint seed
    ) internal {
        //TODO: implement VRF fulfill request function
        Types.MatchInfo storage currMatch = matchInfo[seedRequestIdMatchId[requestId]];

        currMatch.seed = seed;

        currMatch.stage = Types.MATCH_STAGE.RANDOM_SEED_RECEIVED;

        console.log("fullfilSeedRequest - called");

        emit MatchEnteredStage(seedRequestIdMatchId[requestId], currMatch.stage);
    }


    function commitmentTick(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        console.log("commitmentTick - called");

        require(
            currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_RECEIVED 
            || currMatch.stage == Types.MATCH_STAGE.STATE_UPDATE_PERFORMED, 
            "ERR: Match not in correct stage to fetch Commitments!"
        );

        if(currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_RECEIVED){
            _createPlayerStats(matchId);
        }

        console.log("commitmentTickCalled - passed requirement");

        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).requestData();
        }

        currMatch.stage = Types.MATCH_STAGE.COMMITMENTS_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
        console.log("commitmentTick, XPOS for palyer0: %s", teamMove[matchId][0][0].xPos[0]);

    }

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

        console.log("updateCommitmentInfo, XPOS for palyer0: %s", teamMove[matchId][0][0].xPos[0]);

    }

    function _updateTeamMoveCommitments(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {
        Types.TeamMove storage currTeamMove = teamMove[matchId][matchIdToMatchStateId[matchId]][teamId];

        currTeamMove.commitment = payload;
    }
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
        console.log("revealTick, XPOS for palyer0: %s", teamMove[matchId][0][0].xPos[0]);

    }
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
        console.log("updateRevealInfo, XPOS for palyer0: %s", teamMove[matchId][0][0].xPos[0]);

    }

    function _updateTeamMove(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {
        Types.TeamMove storage currTeamMove = teamMove[matchId][matchIdToMatchStateId[matchId]][teamId];

        bytes memory revealHash = abi.encode(keccak256(payload));

        require(
            keccak256(revealHash) == keccak256(currTeamMove.commitment),
            "ERR: Reveal doesn't correspond to the Commitment"  
        );

        currTeamMove.reveal = payload;

        (uint seed, uint packedData) = abi.decode(payload, (uint, uint));

        currTeamMove.seed = seed;

        uint SHIFT_STEP = BITS_PER_PLAYER_X_POS + BITS_PER_PLAYER_Y_POS;

        for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
            uint segment = (packedData >> (playerId * SHIFT_STEP));
            currTeamMove.xPos[playerId] = (segment >> BITS_PER_PLAYER_Y_POS) & (2**BITS_PER_PLAYER_X_POS - 1);
            currTeamMove.yPos[playerId] = segment & (2**BITS_PER_PLAYER_Y_POS - 1);
        }

        currTeamMove.wantToShoot = (packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM) & 1) == 1;
        
        currTeamMove.wantToPass = (packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM + 1) & 1) == 1;

        uint potentialReceivingPlayerId = (packedData >> (SHIFT_STEP * NUMBER_OF_PLAYERS_PER_TEAM + 2) & 0xf);
        currTeamMove.receivingPlayerId = potentialReceivingPlayerId & 7;
    }

    function _setPlayersToInitialPositions(
        uint matchId,
        uint stateId
    ) internal {
        uint teamId = 0;

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

    function _createPlayerStats(
        uint matchId
    ) internal { 
        
        uint seed = matchInfo[matchId].seed;
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
            Types.TeamState storage tState = teamState[matchId][0][teamId];
            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                uint segment = (seed >> ((1+teamId)*playerId*21));
                tState.playerStats[playerId].speed = segment & (2**7-1);
                tState.playerStats[playerId].skill = (segment >> 7) & (2**7-1);
                tState.playerStats[playerId].stamina = (segment >> 14) & (2**7-1);
            }
            tState.goalKeeperStats.speed = ((seed >> (teamId*21)) >> 0) & (2**7-1);
            tState.goalKeeperStats.skill = ((seed >> (teamId*21)) >> 7) & (2**7-1);
            tState.goalKeeperStats.stamina = ((seed >> (teamId*21)) >> 14) & (2**7-1);

        }
    }
}
