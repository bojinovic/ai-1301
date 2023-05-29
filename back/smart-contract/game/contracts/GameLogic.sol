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
    uint constant public SHOOT_STEPS = 2;

    uint constant public BITS_PER_PLAYER_X_POS = 10;
    uint constant public BITS_PER_PLAYER_Y_POS = 9;

    uint constant public MAX_BALL_DISTANCE_REQUIRED = 25;

    uint constant public FIELD_W = 2 ** BITS_PER_PLAYER_X_POS;
    uint constant public FIELD_H = 2 ** BITS_PER_PLAYER_Y_POS;

    uint constant public STAMINA_LOSS_PER_STEP = 2;

    address public logic;
    address public ticker;

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

    function _initStorageForMatch(uint matchId, uint stateId) internal {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("_initStorageForMatch(uint256,uint256)", matchId, stateId));

        require(success, "ERR: _initStorageForMatch Delegate call failed!");
    }

    function _setPlayersToInitialPositions(uint matchId, uint stateId) internal {
       
        (bool success, bytes memory data) = manager.delegatecall(
            abi.encodeWithSignature("_setPlayersToInitialPositions(uint256,uint256)", matchId, stateId));

        require(success, "ERR: _setPlayersToInitialPositions Delegate call failed!");
    }


    function stateUpdate(uint matchId) public {
        Types.MatchInfo storage s_currMatch = matchInfo[matchId];
        uint stateId = matchIdToMatchStateId[matchId];
        _initStorageForMatch(matchId, stateId+1);
        Types.MatchState storage s_currMatchState = matchState[matchId][stateId+1];

        require(
            s_currMatch.stage == Types.MATCH_STAGE.REVEAL_RECEIVED,
            "ERR: Match not in correct stage to perform a State update!"
        ); 


        Types.ProgressionState[] memory progression = getProgression(matchId, stateId);
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

    // function getTeamStateProgression(
    //     uint matchId,
    //     uint stateId,
    //     uint progressionStep,
    //     uint teamId
    // ) public view returns (
    //     uint[10] memory x_pos
    // ){
    //     Types.ProgressionState[] memory progression = getProgression(matchId, stateId);
   
    //     for(uint stepId = 0; stepId < NUMBER_OF_PLAYERS_PER_TEAM; ++stepId){
    //         x_pos[stepId] = progression[progressionStep].teamState[teamId].xPos[stepId];
    //     }
    // }

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
            PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE + SHOOT_STEPS
        );

        uint stepId = 0;
        for(; stepId < PLAYER_STEPS_PER_MOVE + BALL_STEPS_PER_MOVE + SHOOT_STEPS; ++stepId){

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

    function getPlayerPos (
        uint matchId,
        uint stateId,
        uint teamId,
        uint playerId
    ) public view returns (uint x, uint y){
        return (
            teamState[matchId][stateId][teamId].xPos[playerId], 
            teamState[matchId][stateId][teamId].yPos[playerId]
        );
    }
}
