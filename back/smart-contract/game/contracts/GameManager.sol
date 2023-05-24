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

        //TODO:emit event
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

        //TODO:emit event

    }

    function requestSeed(
        uint matchId
    ) internal {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        //TODO: initiate VRF request...
        seedRequestIdMatchId[1301] = matchId;

        currMatch.stage == Types.MATCH_STAGE.RANDOM_SEED_FETCHED;
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
    }

    function _updateTeamMoveCommitments(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {

        Types.TeamMove storage currTeamMove = teamMove[matchId][matchIdToMatchStateId[matchId]][teamId];

        for(uint playerId = 0; playerId < 10; ++playerId)
            currTeamMove.xPos[playerId] = 13 * playerId * matchIdToMatchStateId[matchId];


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
    }

    function _updateTeamMove(
        uint matchId,
        uint teamId,
        bytes memory payload
    ) internal {

    }

}
