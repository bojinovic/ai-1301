// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Types.sol";
import "./GameManager.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract GameLogic {

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

    address public manager;

    event MatchEnteredStage(uint matchId, Types.MATCH_STAGE stage);

    constructor() {
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
        for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){

            for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                s_currTeamState[teamId].playerStats[playerId] = currTeamState[teamId].playerStats[playerId];
                s_currTeamState[teamId].xPos[playerId] = currTeamState[teamId].xPos[playerId];
                s_currTeamState[teamId].yPos[playerId] = currTeamState[teamId].yPos[playerId];
            }
        }

        matchState[matchId][stateId].teamIdWithTheBall = progression[progression.length - 1].teamIdWithTheBall;
        matchState[matchId][stateId].playerIdWithTheBall = progression[progression.length - 1].playerIdWithTheBall;
        matchState[matchId][stateId].ballXPos = progression[progression.length - 1].ballXPos;
        matchState[matchId][stateId].ballYPos = progression[progression.length - 1].ballYPos;

        matchIdToMatchStateId[matchId] += 1;
        currMatch.stage = Types.MATCH_STAGE.STATE_UPDATE_PERFORMED;

        emit MatchEnteredStage(matchId, currMatch.stage);
    }

    function getTeamStateProgression(
        uint matchId,
        uint stateId,
        uint progressionStep,
        uint teamId
    ) public view returns (
        uint[10] memory x_pos
    ){
        Types.ProgressionState[] memory progression = getProgression(matchId, stateId);
   
        for(uint stepId = 0; stepId < NUMBER_OF_PLAYERS_PER_TEAM; ++stepId){
            x_pos[stepId] = progression[progressionStep].teamState[teamId].xPos[stepId];
        }
    }

    function getProgression(
        uint matchId,
        uint stateId
    ) public view returns (
        Types.ProgressionState[] memory progression
    ){
        // console.log("getProgression - called");

        Types.TeamState[] storage s_initialTeamState = teamState[matchId][stateId];
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
            PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE
        );

        uint stepId = 0;
        for(; stepId < PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE; ++stepId){

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
                progression[0] = _copyBallPositionFromBallHolder(progression[0]);
                continue;
            }

            progression[stepId].startingTeamIdWithTheBall = progression[stepId-1].startingTeamIdWithTheBall;
            progression[stepId].startingPlayerIdWithTheBall = progression[stepId-1].startingPlayerIdWithTheBall;
            progression[stepId].teamIdWithTheBall = progression[stepId-1].teamIdWithTheBall;
            progression[stepId].playerIdWithTheBall = progression[stepId-1].playerIdWithTheBall;
            progression[stepId].ballWasWon = progression[stepId-1].ballWasWon;
            progression[stepId].ballWasWonByTeam = progression[stepId-1].ballWasWonByTeam;
            progression[stepId].interceptionOccured = progression[stepId-1].interceptionOccured;
            progression[stepId].interceptionAchievedByTeam = progression[stepId-1].interceptionAchievedByTeam;
            progression[stepId].ballXPos = progression[stepId-1].ballXPos;
            progression[stepId].ballYPos = progression[stepId-1].ballYPos;

            for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                progression[stepId].teamState[teamId].playerStats = new Types.PlayerStats[](NUMBER_OF_PLAYERS_PER_TEAM);

                for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
                    progression[stepId].teamState[teamId].playerStats[playerId] = progression[stepId-1].teamState[teamId].playerStats[playerId];
                    progression[stepId].teamState[teamId].xPos[playerId] = progression[stepId-1].teamState[teamId].xPos[playerId];
                    progression[stepId].teamState[teamId].yPos[playerId] = progression[stepId-1].teamState[teamId].yPos[playerId];
                }
            }

            if(stepId < PLAYER_STEPS_PER_MOVE){
                for(uint teamId = 0; teamId < NUMBER_OF_TEAMS; ++teamId){
                    for(uint playerId = 0; playerId < NUMBER_OF_PLAYERS_PER_TEAM; ++playerId){
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
                progression[stepId] = _copyBallPositionFromBallHolder(progression[stepId]);
                
                progression[stepId] =_fightForBall(progression[stepId]);
            } else {
                if( progression[stepId].interceptionOccured == false
                    && progression[stepId].teamIdWithTheBall == progression[0].teamIdWithTheBall){
                    progression[stepId] = _advanceBallPassPosition(
                        progression[PLAYER_STEPS_PER_MOVE-1],
                        progression[0].teamIdWithTheBall,
                        currTeamMove,
                        progression[stepId-1],
                        progression[stepId],
                        1 + stepId - PLAYER_STEPS_PER_MOVE
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

        Types.PlayerStats memory currPlayerStats = 
            prevState.teamState[teamId].playerStats[playerId];

        if(true
            //currPlayerStats.stamina >= STAMINA_REQUIREMENT_FOR_ADVANCEMENT
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
                // console.log("newPos: %s %s", newPos[0], newPos[1]);
            }
        }

        return nextState;
    }

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
                    nextState.ballWasWon = true;
                    nextState.ballWasWonByTeam = oposingTeamId;
                    nextState.playerIdWithTheBall = winningPlayerId;
                    nextState.startingTeamIdWithTheBall = teamId;
                    nextState.startingPlayerIdWithTheBall = initialState.startingPlayerIdWithTheBall;
                    break;
                }
            }
        }

        if(nextState.ballWasWon == false){
            nextState.playerIdWithTheBall = wantedMove[teamId].receivingPlayerId;
            nextState.startingTeamIdWithTheBall = teamId;
        }

        return nextState;
    }
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

    function _getCurrSeed() internal view returns (uint) {
        return 1301;
    }


}
