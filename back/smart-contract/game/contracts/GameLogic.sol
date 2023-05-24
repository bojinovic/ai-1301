// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Constants.sol";
import "./Types.sol";
import "./GameManager.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
import "hardhat/console.sol";

contract GameLogic {

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

    address public manager;

    constructor() {
        constants = new Constants();
        manager = address(new GameManager(address(this)));
    }


    function createMatch(
        address team1_commitmentChainlinkFunctionConsumer, 
        address team1_revealChainlinkFunctionConsumer
    ) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("createMatch(address,address)", team1_commitmentChainlinkFunctionConsumer, team1_revealChainlinkFunctionConsumer));

        require(success, "ERR: createMatch Delegate call failed!");

    }

    function joinMatch(
        uint matchId,
        address team2_commitmentChainlinkFunctionConsumer, 
        address team2_revealChainlinkFunctionConsumer
    ) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("joinMatch(uint256,address,address)", matchId, team2_commitmentChainlinkFunctionConsumer, team2_revealChainlinkFunctionConsumer));

        require(success, "ERR: joinMatch Delegate call failed!");
    }


    function commitmentTick(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("commitmentTick(uint256)", matchId));

        require(success, "ERR: commitmentTick Delegate call failed!");
    }

    function updateCommitmentInfo(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("updateCommitmentInfo(uint256)", matchId));

        require(success, "ERR: updateCommitmentInfo Delegate call failed!");
    }

    function revealTick(uint matchId) public {

        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("revealTick(uint256)", matchId));

        require(success, "ERR: revealTick Delegate call failed!");
    }

    function updateRevealInfo(uint matchId) public {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("updateRevealInfo(uint256)", matchId));

        require(success, "ERR: updateRevealInfo Delegate call failed!");
    }


    function stateUpdate(uint matchId) public {
        Types.MatchInfo storage currMatch = matchInfo[matchId];

        require(
            currMatch.stage == Types.MATCH_STAGE.REVEAL_RECEIVED,
            "ERR: Match not in correct stage to perform a State update!"
        ); 

        uint stateId = matchIdToMatchStateId[matchId];
        Types.ProgressionState[] memory progression = getProgression(matchId, stateId);

        Types.TeamState[] memory currTeamState = progression[progression.length - 1].teamState;
        Types.TeamState[] storage s_currTeamState = teamState[matchId][stateId+1];
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){

            for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                s_currTeamState[teamId].playerStats[playerId] = currTeamState[teamId].playerStats[playerId];
                s_currTeamState[teamId].xPos[playerId] = currTeamState[teamId].xPos[playerId];
                s_currTeamState[teamId].yPos[playerId] = currTeamState[teamId].yPos[playerId];
            }
        }

        matchIdToMatchStateId[matchId] += 1;
        currMatch.stage = Types.MATCH_STAGE.STATE_UPDATE_PERFORMED;
    }

    function getTeamStateProgression(
        uint matchId,
        uint stateId,
        uint teamId
    ) public view returns (
        uint[10] memory x_pos
    ){
        Types.ProgressionState[] memory progression = getProgression(matchId, stateId);
   
        for(uint stepId = 0; stepId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++stepId){
            x_pos[stepId] = progression[2].teamState[teamId].xPos[stepId];
        }
    }

    function getProgression(
        uint matchId,
        uint stateId
    ) public view returns (
        Types.ProgressionState[] memory progression
    ){
        console.log("getProgression - called");

        Types.TeamState[] storage s_initialTeamState = teamState[matchId][stateId];
        Types.TeamState[] memory initialTeamState = s_initialTeamState;
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            initialTeamState[teamId].playerStats = new Types.PlayerStats[](constants.NUMBER_OF_PLAYERS_PER_TEAM());

            for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                initialTeamState[teamId].playerStats[playerId] = s_initialTeamState[teamId].playerStats[playerId];
                initialTeamState[teamId].xPos[playerId] = s_initialTeamState[teamId].xPos[playerId];
                initialTeamState[teamId].yPos[playerId] = s_initialTeamState[teamId].yPos[playerId];
            }
        }

        Types.TeamMove[] storage s_currTeamMove = teamMove[matchId][stateId];
        Types.TeamMove[] memory currTeamMove = s_currTeamMove;
        for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
            for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                currTeamMove[teamId].xPos[playerId] = s_currTeamMove[teamId].xPos[playerId];
                currTeamMove[teamId].yPos[playerId] = s_currTeamMove[teamId].yPos[playerId];
            }
        }


        progression = new Types.ProgressionState[](
            constants.PLAYER_STEPS_PER_MOVE() + constants.BALL_STEPS_PER_MOVE()
        );

        uint stepId = 0;
        for(; stepId < constants.PLAYER_STEPS_PER_MOVE() + constants.BALL_STEPS_PER_MOVE(); ++stepId){

            Types.ProgressionState memory currProgressionState = progression[stepId];
            
            currProgressionState.teamState = new Types.TeamState[](constants.NUMBER_OF_TEAMS());
            for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
                Types.TeamState memory currTeamState = currProgressionState.teamState[teamId];
                currTeamState.playerStats = new Types.PlayerStats[](constants.NUMBER_OF_PLAYERS_PER_TEAM());
                currTeamState.xPos = new uint[](constants.NUMBER_OF_PLAYERS_PER_TEAM());
                currTeamState.yPos = new uint[](constants.NUMBER_OF_PLAYERS_PER_TEAM());
            }

            if(stepId == 0){
                currProgressionState.teamState = initialTeamState;
                continue;
            }

            progression[stepId] = progression[stepId-1];
            for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
                progression[stepId].teamState[teamId].playerStats = new Types.PlayerStats[](constants.NUMBER_OF_PLAYERS_PER_TEAM());

                for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                    progression[stepId].teamState[teamId].playerStats[playerId] =  progression[stepId-1].teamState[teamId].playerStats[playerId];
                    progression[stepId].teamState[teamId].xPos[playerId] =  progression[stepId-1].teamState[teamId].xPos[playerId];
                    progression[stepId].teamState[teamId].yPos[playerId] =  progression[stepId-1].teamState[teamId].yPos[playerId];
                }
            }


            for(uint teamId = 0; teamId < constants.NUMBER_OF_TEAMS(); ++teamId){
                for(uint playerId = 0; playerId < constants.NUMBER_OF_PLAYERS_PER_TEAM(); ++playerId){
                    progression[stepId] = _advancePlayerPosition(
                        initialTeamState,
                        currTeamMove, 
                        teamId, 
                        playerId,
                        progression[stepId-1], 
                        progression[stepId], 
                        stepId
                    );
                }
            }

        }
    }

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

        Types.PlayerStats memory currPlayerStats = prevState.teamState[teamId].playerStats[playerId];

        if(true
            //currPlayerStats.stamina >= constants.STAMINA_REQUIREMENT_FOR_ADVANCEMENT()
            //&& currPlayerStats.speed * constants.PLAYER_STEPS_PER_MOVE() >= distance
        ){
            //player can move
            uint[2] memory newPos = [
                diff[0] > 0 ? 
                    (currPos[0] + (wantedPos[0] - initialPos[0]) / constants.PLAYER_STEPS_PER_MOVE())
                    :(currPos[0] - (initialPos[0] - wantedPos[0]) / constants.PLAYER_STEPS_PER_MOVE()),
                diff[1] > 0 ? 
                    (currPos[1] + (wantedPos[1] - initialPos[1]) / constants.PLAYER_STEPS_PER_MOVE())
                    :(currPos[1] - (initialPos[1] - wantedPos[1]) / constants.PLAYER_STEPS_PER_MOVE())
            ];

            nextState.teamState[teamId].xPos[playerId] = newPos[0];
            nextState.teamState[teamId].yPos[playerId] = newPos[1];
            console.log("newPos: %s %s", newPos[0], newPos[1]);
        }


        return nextState;
    }




}
