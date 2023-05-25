// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Constants.sol";
import "./Types.sol";
import "./GameLogic.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
import "hardhat/console.sol";

contract GameManager {

    Constants public constants;
    address public logic;
    address public ticker;


    uint public matchCounter;

    mapping(uint => Types.MatchInfo) public matchInfo;
    mapping(uint => uint) public seedRequestIdMatchId;
    mapping(uint => uint) public matchIdToMatchStateId;
    mapping(uint => mapping(uint => Types.MatchState)) matchState;
    mapping(uint => mapping(uint => Types.TeamState[])) public teamState;
    mapping(uint => mapping(uint => Types.TeamMove[])) public teamMove;

    event MatchEnteredStage(uint matchId, Types.MATCH_STAGE stage);
    constructor(address _logic) {
        constants = new Constants();
        logic = _logic;
    }

    function _initStorageForMatch(
        uint matchId, 
        uint currMoveId
    ) internal {

        if(currMoveId == 0){
            for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
                matchInfo[matchId].commitmentFunctionConsumer.push();
                matchInfo[matchId].revealFunctionConsumer.push();
            }
        }

        Types.MatchState storage currMatchState = matchState[matchId][currMoveId];
        Types.TeamState[] storage currTeamState = teamState[matchId][currMoveId];
        Types.TeamMove[] storage currTeamMove = teamMove[matchId][currMoveId];
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){

            currMatchState.score.push(0);

            currTeamState.push();
            for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                currTeamState[teamId].playerStats.push();

                currTeamState[teamId].xPos.push();
                currTeamState[teamId].yPos.push();
            }

            currTeamMove.push();
            for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
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

        fullfilSeedRequest(1301, 782491124151251301);

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

        _initStorageForMatch(matchId, matchIdToMatchStateId[matchId]+1);

        console.log("commitmentTickCalled - passed requirement");

        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).requestData();
        }

        currMatch.stage = Types.MATCH_STAGE.COMMITMENTS_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    function updateCommitmentInfo(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.COMMITMENTS_FETCHED,
            "ERR: Match not in correct stage to receive Commitments!"
        );        
        
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            require(
                IChainlinkFunctionConsumer(currMatch.commitmentFunctionConsumer[teamId]).dataIsReady(),
                "ERR: Not all teams have issued commitments!"
            );
        }

        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
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
    function revealTick(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.COMMITMENTS_RECEIVED,
            "ERR: Match not in correct stage to fetch Reaveals!"
        );

        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).requestData();
        }

        currMatch.stage = Types.MATCH_STAGE.REVEALS_FETCHED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }
    function updateRevealInfo(
        uint matchId
    ) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.REVEALS_FETCHED,
            "ERR: Match not in correct stage to receive Reveals!"
        );        
        
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            require(
                IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).dataIsReady(),
                "ERR: Not all teams have issued commitments!"
            );
        }

        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            _updateTeamMove(
                matchId, 
                teamId,
                IChainlinkFunctionConsumer(currMatch.revealFunctionConsumer[teamId]).copyData()
            );      
        }

        currMatch.stage = Types.MATCH_STAGE.REVEAL_RECEIVED;

        emit MatchEnteredStage(matchId, currMatch.stage);
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

        uint SHIFT_STEP = constants.BITS_PER_PLAYER_X_POS() + constants.BITS_PER_PLAYER_Y_POS();

        for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
            uint segment = (packedData >> (playerId * SHIFT_STEP));
            currTeamMove.xPos[playerId] = (segment >> constants.BITS_PER_PLAYER_Y_POS()) & (2**constants.BITS_PER_PLAYER_X_POS() - 1);
            currTeamMove.yPos[playerId] = segment & (2**constants.BITS_PER_PLAYER_Y_POS() - 1);
        }

        currTeamMove.wantToShoot = (packedData >> (SHIFT_STEP * constants.NUMBER_OF_PLAYERS_PER_TEAM()) & 1) == 1;
        
        currTeamMove.wantToPass = (packedData >> (SHIFT_STEP * constants.NUMBER_OF_PLAYERS_PER_TEAM() + 1) & 1) == 1;
        currTeamMove.receivingPlayerId = (packedData >> (SHIFT_STEP * constants.NUMBER_OF_PLAYERS_PER_TEAM() + 2) & 0xf);
    }

}
