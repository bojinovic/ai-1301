// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Game {

    uint constant public PLAYER_STEPS_PER_MOVE = 5;
    uint constant public BALL_STEPS_PER_MOVE = 7;

    uint constant MAX_BALL_DISTANCE_REQUIRED = 5;

    uint constant public FIELD_W = 100;
    uint constant public FIELD_H = 50;

    address public ticker;

    struct PlayerStats {
        uint speed;
        uint skill;
        uint stamina;
    }

    struct MatchInfo {
        uint seed;

        PlayerStats[10] team1_playerStats;
        PlayerStats[10] team2_playerStats;

        address team1_commitmentChainlinkFunctionConsumer;
        address team2_commitmentChainlinkFunctionConsumer;

        address team1_revealChainlinkFunctionConsumer;
        address team2_revealmentChainlinkFunctionConsumer;
    }

    struct MoveInfo {
        PlayerStats[10] team1_playerStats;
        PlayerStats[10] team2_playerStats;

        uint[] team1_x_positions;
        uint[10] team2_x_positions;
        uint[10] team1_y_positions;
        uint[10] team2_y_positions;

        uint team1_seed;
        uint team2_seed;

        uint team_with_the_ball;
        uint player_id_with_the_ball;

        bool pass;
        uint[7] pass_ball_x_positions;
        uint[7] pass_ball_y_positions;
        uint receiving_player_id;
        bool interceptionOcurred;

        bool shoot;
    }

    uint public matchCounter;
    mapping(uint => MatchInfo) public matches;
    mapping(uint => uint) public matchIdToMoveId;
    mapping(uint => mapping(uint => MoveInfo)) public matchProgression;
    
    constructor() {

        uint NUM_MOVES = 30;
        for(uint i = 0; i < NUM_MOVES; ++i){

            matchProgression[matchCounter][i].team1_x_positions = new uint[](10);
            matchProgression[matchCounter][i].team1_x_positions[0] = i;

            matchProgression[matchCounter][i].team1_y_positions = [(i*3)%FIELD_H];


            matchProgression[matchCounter][i].team2_x_positions;
            matchProgression[matchCounter][i].team2_y_positions;

            matchProgression[matchCounter][i].pass = true;
            matchProgression[matchCounter][i].team_with_the_ball = 1;
            matchProgression[matchCounter][i].player_id_with_the_ball = i%10;
            matchProgression[matchCounter][i].receiving_player_id = (1+i)%10;

        }

        matchIdToMoveId[matchCounter] = NUM_MOVES;

        matchCounter += 1;
    }

    function createMatch() public {}

    function joinMatch() public {}

    function commitmentTick() public {}

    function updateCommitmentInfo(uint matchId, bytes memory commitment) public {}

    function revealTick() public {}

    function updateRevealInfo(uint matchId, bytes memory commitment) public {}

    function stateUpdateTick(uint matchId, MoveInfo memory reportedMoveInfo) public {
    
    }


    function dispute() public {

    }


    function playout(uint matchId, uint previousMoveId) public view returns (MoveInfo memory move, MoveInfo[5] memory moveProgression) {

        move= matchProgression[matchId][previousMoveId];
        move.team1_x_positions = new uint[](10);
        for(uint i = 0; i < 10; ++i){
            move.team1_x_positions[i] =  matchProgression[matchId][previousMoveId].team1_x_positions[i] ;
        }

        MoveInfo storage currMove = matchProgression[matchId][previousMoveId+1];

        //player movements
        for(uint remainingSteps = PLAYER_STEPS_PER_MOVE; remainingSteps > 0; remainingSteps--){
            for(uint playerId = 0; playerId < 10; ++playerId){
                uint wantedX = currMove.team1_x_positions[playerId];
                uint wantedY = currMove.team1_y_positions[playerId];
                (uint playerPosX, uint playerPosY) = _advancePlayerPosition(move, 1, playerId, wantedX, wantedY, remainingSteps);
                
                move.team1_x_positions[playerId] = playerPosX;
                move.team1_y_positions[playerId] = playerPosY;
            }
            for(uint playerId = 0; playerId < 10; ++playerId){
                uint wantedX = currMove.team2_x_positions[playerId];
                uint wantedY = currMove.team2_y_positions[playerId];
                (uint playerPosX, uint playerPosY) = _advancePlayerPosition(move, 2, playerId, wantedX, wantedY, remainingSteps);
                
                move.team2_x_positions[playerId] = playerPosX;
                move.team2_y_positions[playerId] = playerPosY;
            }

            moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].team1_x_positions = new uint[](10);

            for(uint i = 0; i < 10; ++i){
                moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].team1_x_positions[i] = move.team1_x_positions[i];
                moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].team1_y_positions[i] = move.team1_y_positions[i];
            }

            //TODO: interceptions
        }

        //ball movement during a pass
        if(move.pass == true && move.interceptionOcurred == false){

            uint playerIdWithTheBall = move.player_id_with_the_ball;
            uint receivingPlayerId =  move.receiving_player_id;
            uint wantedX;
            uint wantedY;

            if(move.team_with_the_ball == 1){
                move.pass_ball_x_positions[0] = move.team1_x_positions[playerIdWithTheBall];
                move.pass_ball_y_positions[0] = move.team1_y_positions[playerIdWithTheBall];

                wantedX = move.team1_x_positions[receivingPlayerId];
                wantedY = move.team1_y_positions[receivingPlayerId];
            } else {
                move.pass_ball_x_positions[0] = move.team2_x_positions[playerIdWithTheBall];
                move.pass_ball_y_positions[0] = move.team2_y_positions[playerIdWithTheBall];

                wantedX = move.team2_x_positions[receivingPlayerId];
                wantedY = move.team2_y_positions[receivingPlayerId];
            }

            for(uint stepId = 1; stepId < BALL_STEPS_PER_MOVE && move.interceptionOcurred == false; stepId++){
                _advanceBallPosition(move, wantedX, wantedY, stepId);
            }
        }

        // moveProgression[PLAYER_STEPS_PER_MOVE-1] = _copyMoveInfo(move);
        for(uint i = 0; i < 10; ++i){
            moveProgression[PLAYER_STEPS_PER_MOVE-1].team1_x_positions[i] = move.team1_x_positions[i];
            moveProgression[PLAYER_STEPS_PER_MOVE-1].team1_y_positions[i] = move.team1_y_positions[i];

        }
    }

    function _copyMoveInfo(MoveInfo memory src) internal view returns (MoveInfo memory dest) {

        PlayerStats[10] memory team1_playerStats;
        // PlayerStats[10] memory team2_playerStats;

    
        uint[10] memory team1_x_positions;
        // uint[10] memory team2_x_positions;

        uint[10] memory team1_y_positions;
        // uint[10] memory team2_y_positions;

        uint team1_seed;
        uint team2_seed;

        uint team_with_the_ball;
        uint player_id_with_the_ball;

        bool pass;
        uint[7] memory pass_ball_x_positions;
        uint[7] memory pass_ball_y_positions;
        uint receiving_player_id;
        bool interceptionOcurred;

        bool shoot;

        // dest = MoveInfo({
        //     team1_playerStats:team1_playerStats,
        //     team2_playerStats:team1_playerStats,
        //     team1_x_positions:team1_x_positions,
        //     team2_x_positions:team1_x_positions,
        //     team1_y_positions:team1_y_positions,
        //     team2_y_positions:team1_y_positions,
        //     team1_seed:team1_seed,
        //     team2_seed:team2_seed,
        //     team_with_the_ball:team_with_the_ball,
        //     player_id_with_the_ball:player_id_with_the_ball,
        //     pass:pass,
        //     pass_ball_x_positions: pass_ball_x_positions,
        //     pass_ball_y_positions:pass_ball_y_positions,
        //     receiving_player_id:receiving_player_id,
        //     interceptionOcurred:interceptionOcurred,
        //     shoot:shoot
        // });

        dest.pass = src.pass;
        dest.player_id_with_the_ball = src.player_id_with_the_ball;
        dest.receiving_player_id = src.receiving_player_id;


        for(uint i = 0; i < 10; ++i){
            dest.team1_playerStats[i].speed = src.team1_playerStats[i].speed;
            dest.team2_playerStats[i].speed = src.team2_playerStats[i].speed;

            dest.team1_playerStats[i].skill = src.team1_playerStats[i].skill;
            dest.team2_playerStats[i].skill = src.team2_playerStats[i].skill;

            dest.team1_playerStats[i].stamina = src.team1_playerStats[i].stamina;
            dest.team2_playerStats[i].stamina = src.team2_playerStats[i].stamina;

            // dest.team1_x_positions[i] = src.team1_x_positions[i];
            dest.team2_x_positions[i] = src.team2_x_positions[i];

            dest.team1_y_positions[i] = src.team1_y_positions[i];
            dest.team2_y_positions[i] = src.team2_y_positions[i];

            if(i < BALL_STEPS_PER_MOVE){
                dest.pass_ball_x_positions[i] = src.pass_ball_x_positions[i];
                dest.pass_ball_y_positions[i] = src.pass_ball_y_positions[i];
            }
        }
    }

    function _advancePlayerPosition(MoveInfo memory move, uint teamId, uint playerId, uint wantedX, uint wantedY, uint remainingSteps) internal view returns (uint newX, uint newY) {
        //TODO: requires... check if the move is possible at all

        uint currX = move.team1_x_positions[playerId];
        uint currY = move.team1_y_positions[playerId];
        
        if(teamId == 2){
            currX = move.team2_x_positions[playerId];
            currY = move.team2_y_positions[playerId];
        }

        if(currX == wantedX && currY == wantedY){

            return (currX, currY);
        }

        if(remainingSteps == 0 
            || _pointWithinTheField(wantedX, wantedY) == false){

            return (currX, currY);
        }

        if(remainingSteps == 1){
            return (wantedX, wantedY);
        } 

        int diffX = int(wantedX) - int(currX);
        int diffY = int(wantedY) - int(currY);

        if(diffX > 0){

            newX = currX + uint((1000 * diffX) / int(remainingSteps)) / 1000;
        }else if (diffX < 0){

            newX = currX - uint((1000 * -diffX) / int(remainingSteps)) / 1000;

        }else{
            newX = wantedX;
        }

        if(diffY > 0){
            newY = currY + uint((1000 * diffY) / int(remainingSteps)) / 1000;
        }else if (diffY < 0){
            newY = currY - uint((1000 * -diffY) / int(remainingSteps) / 1000);
        }else{
            newY = wantedY;
        }
    }

    function _advanceBallPosition(MoveInfo memory move, uint wantedX, uint wantedY, uint stepId) internal view returns (uint newX, uint newY) {
        //TODO: requires... check if the move is possible at all

        console.log("ADVANCING BALL");

        uint currX = move.pass_ball_x_positions[stepId-1];
        uint currY = move.pass_ball_y_positions[stepId-1];

        uint remainingSteps = BALL_STEPS_PER_MOVE - stepId;

        if(remainingSteps == 1) {
            move.pass_ball_x_positions[stepId] = wantedX;
            move.pass_ball_y_positions[stepId] = wantedY;
        } else {

            int diffX = int(wantedX) - int(currX);
            int diffY = int(wantedY) - int(currY);


            if(diffX > 0){

                move.pass_ball_x_positions[stepId] = currX + uint((1000 * diffX) / int(remainingSteps)) / 1000;
            }else if (diffX < 0){

                move.pass_ball_x_positions[stepId] = currX - uint((1000 * -diffX) / int(remainingSteps)) / 1000;
            }

            if(diffY > 0){
                move.pass_ball_y_positions[stepId]  = currY + uint((1000 * diffY) / int(remainingSteps)) / 1000;
            }else if (diffX < 0){
                move.pass_ball_y_positions[stepId] = currY - uint((1000 * -diffY) / int(remainingSteps) / 1000);
            }
        }

        //interceptions
        if(move.team_with_the_ball == 2){
            for(uint playerId = 0; playerId < 10; ++playerId){

                uint dist = uint((int(newX) - int(move.team1_x_positions[playerId]))**2) + uint((int(newY) - int(move.team1_y_positions[playerId]))**2);

                if(dist < MAX_BALL_DISTANCE_REQUIRED && false){
                    move.team_with_the_ball = 1;
                    move.interceptionOcurred = true;
                    move.player_id_with_the_ball = playerId;
                    break;
                }
            }
        } else{
            for(uint playerId = 0; playerId < 10; ++playerId){
                uint playerPosX = move.team2_x_positions[playerId];
                uint playerPosY = move.team2_y_positions[playerId];

                uint dist = uint((int(newX) - int(playerPosX))**2) + uint((int(newY) - int(playerPosY))**2);

                if(dist < MAX_BALL_DISTANCE_REQUIRED && false){
                    move.team_with_the_ball = 2;
                    move.interceptionOcurred = true;
                    move.player_id_with_the_ball = playerId;
                    break;
                }
            }
        }
    }


    function _pointWithinTheField(uint x, uint y) internal view returns (bool) {
        return x < FIELD_W && y < FIELD_H;
    }

    function _playerStatsAllowTheAdvancment(PlayerStats memory playerStats, uint diffX, uint diffY) internal view returns (bool) {
        //TODO: ...
        return true;
    }
}
