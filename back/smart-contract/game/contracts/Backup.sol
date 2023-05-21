// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import "./Types.sol";
// import "./interfaces/IChainlinkFunctionConsumer.sol";


// // Uncomment this line to use console.log
// // import "hardhat/console.sol";

// contract GameLogic {


    

//     constructor() {
      
//     }

//     function playout(
//         Types.MoveInfo storage curr,
//         Types.MoveInfo storage next, 
//         Types.MoveInfo[5] storage progression
//     ) public {

        
//         next.state.team1_x_positions = new uint[](10);
//         curr.state.team1_x_positions = new uint[](10);
//         curr.state.team2_x_positions = new uint[](10);
//         curr.state.team1_y_positions = new uint[](10);
//         curr.state.team2_y_positions = new uint[](10);

//         move.state.pass_ball_x_positions = new uint[](7);
//         move.state.pass_ball_y_positions = new uint[](7);

//         for(uint i = 0; i < 10; ++i){
//             move.state.team1_x_positions[i] =  matchProgression[matchId][previousMoveId].state.team1_x_positions[i] ;
//         }

//         Types.MoveInfo storage currMove = matchProgression[matchId][previousMoveId+1];

//         //player movements
//         for(uint remainingSteps = PLAYER_STEPS_PER_MOVE; remainingSteps > 0; remainingSteps--){
//             for(uint playerId = 0; playerId < 10; ++playerId){
//                 uint wantedX = currMove.state.team1_x_positions[playerId];
//                 uint wantedY = currMove.state.team1_y_positions[playerId];
//                 (uint playerPosX, uint playerPosY) = _advancePlayerPosition(move, 1, playerId, wantedX, wantedY, remainingSteps);
                
//                 move.state.team1_x_positions[playerId] = playerPosX;
//                 move.state.team1_y_positions[playerId] = playerPosY;
//             }
//             for(uint playerId = 0; playerId < 10; ++playerId){
//                 uint wantedX = currMove.state.team2_x_positions[playerId];
//                 uint wantedY = currMove.state.team2_y_positions[playerId];
//                 (uint playerPosX, uint playerPosY) = _advancePlayerPosition(move, 2, playerId, wantedX, wantedY, remainingSteps);
                
//                 move.state.team2_x_positions[playerId] = playerPosX;
//                 move.state.team2_y_positions[playerId] = playerPosY;
//             }

//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team1_x_positions = new uint[](10);
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team1_x_positions = new uint[](10);
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team2_x_positions = new uint[](10);
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team1_y_positions = new uint[](10);
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team2_y_positions = new uint[](10);

//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.pass_ball_x_positions = new uint[](7);
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.pass_ball_y_positions = new uint[](7);

//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.pass = move.state.pass;
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.player_id_with_the_ball = move.state.player_id_with_the_ball;
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team_with_the_ball = move.state.team_with_the_ball;
//             moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.receiving_player_id = move.state.receiving_player_id;


//             for(uint i = 0; i < 10; ++i){
//                 moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team1_x_positions[i] = move.state.team1_x_positions[i];
//                 moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team1_y_positions[i] = move.state.team1_y_positions[i];
//                 moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team2_x_positions[i] = move.state.team2_x_positions[i];
//                 moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.team2_y_positions[i] = move.state.team2_y_positions[i];
//                 if(i < BALL_STEPS_PER_MOVE){
//                     moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.pass_ball_x_positions[i] = move.state.pass_ball_x_positions[i];
//                     moveProgression[PLAYER_STEPS_PER_MOVE-remainingSteps].state.pass_ball_y_positions[i] = move.state.pass_ball_y_positions[i];
//                 }
//             }

//             //TODO: interceptions
//         }


//         //ball movement during a pass
//         if(move.state.pass == true && move.state.interceptionOcurred == false){

//             uint playerIdWithTheBall = move.state.player_id_with_the_ball;
//             uint receivingPlayerId =  move.state.receiving_player_id;
//             uint wantedX;
//             uint wantedY;

//             if(move.state.team_with_the_ball == 1){
//                 move.state.pass_ball_x_positions[0] = move.state.team1_x_positions[playerIdWithTheBall];
//                 move.state.pass_ball_y_positions[0] = move.state.team1_y_positions[playerIdWithTheBall];

//                 wantedX = move.state.team1_x_positions[receivingPlayerId];
//                 wantedY = move.state.team1_y_positions[receivingPlayerId];
//             } else {
//                 move.state.pass_ball_x_positions[0] = move.state.team2_x_positions[playerIdWithTheBall];
//                 move.state.pass_ball_y_positions[0] = move.state.team2_y_positions[playerIdWithTheBall];

//                 wantedX = move.state.team2_x_positions[receivingPlayerId];
//                 wantedY = move.state.team2_y_positions[receivingPlayerId];
//             }


//             for(uint stepId = 1; stepId < BALL_STEPS_PER_MOVE && move.state.interceptionOcurred == false; stepId++){
//                 (uint newX, uint newY) =_advanceBallPosition(move.state.pass_ball_x_positions[0], move.state.pass_ball_y_positions[0], wantedX, wantedY, stepId);
//                 move.state.pass_ball_x_positions[stepId] = newX;
//                 move.state.pass_ball_y_positions[stepId] = newY;

//             }
//         }

//         moveProgression[PLAYER_STEPS_PER_MOVE-1].state.pass = move.state.pass;
//         moveProgression[PLAYER_STEPS_PER_MOVE-1].state.player_id_with_the_ball = move.state.player_id_with_the_ball;
//         moveProgression[PLAYER_STEPS_PER_MOVE-1].state.team_with_the_ball = move.state.team_with_the_ball;
//         moveProgression[PLAYER_STEPS_PER_MOVE-1].state.receiving_player_id = move.state.receiving_player_id;

//         for(uint i = 0; i < 10; ++i){
//             moveProgression[PLAYER_STEPS_PER_MOVE-1].state.team1_x_positions[i] = move.state.team1_x_positions[i];
//             moveProgression[PLAYER_STEPS_PER_MOVE-1].state.team1_y_positions[i] = move.state.team1_y_positions[i];
//             moveProgression[PLAYER_STEPS_PER_MOVE-1].state.team2_x_positions[i] = move.state.team2_x_positions[i];
//             moveProgression[PLAYER_STEPS_PER_MOVE-1].state.team2_y_positions[i] = move.state.team2_y_positions[i];
//             if(i < BALL_STEPS_PER_MOVE){
//                 moveProgression[PLAYER_STEPS_PER_MOVE-1].state.pass_ball_x_positions[i] = move.state.pass_ball_x_positions[i];
//                 moveProgression[PLAYER_STEPS_PER_MOVE-1].state.pass_ball_y_positions[i] = move.state.pass_ball_y_positions[i];
//             }
//         }
//     }

  

//     function _advancePlayerPosition(Types.MoveInfo memory move, uint teamId, uint playerId, uint wantedX, uint wantedY, uint remainingSteps) internal view returns (uint newX, uint newY) {
//         //TODO: requires... check if the move is possible at all

//         uint currX = move.state.team1_x_positions[playerId];
//         uint currY = move.state.team1_y_positions[playerId];
        
//         if(teamId == 2){
//             currX = move.state.team2_x_positions[playerId];
//             currY = move.state.team2_y_positions[playerId];
//         }

//         if(currX == wantedX && currY == wantedY){

//             return (currX, currY);
//         }

//         if(remainingSteps == 0 
//             || _pointWithinTheField(wantedX, wantedY) == false){

//             return (currX, currY);
//         }

//         if(remainingSteps == 1){
//             return (wantedX, wantedY);
//         } 

//         int diffX = int(wantedX) - int(currX);
//         int diffY = int(wantedY) - int(currY);

//         if(diffX > 0){

//             newX = currX + uint((1000 * diffX) / int(remainingSteps)) / 1000;
//         }else if (diffX < 0){

//             newX = currX - uint((1000 * -diffX) / int(remainingSteps)) / 1000;

//         }else{
//             newX = wantedX;
//         }

//         if(diffY > 0){
//             newY = currY + uint((1000 * diffY) / int(remainingSteps)) / 1000;
//         }else if (diffY < 0){
//             newY = currY - uint((1000 * -diffY) / int(remainingSteps) / 1000);
//         }else{
//             newY = wantedY;
//         }
//     }

//     function _advanceBallPosition(uint startX, uint startY, uint wantedX, uint wantedY, uint stepId) internal view returns (uint newX, uint newY) {
//         //TODO: requires... check if the move is possible at all


//         uint remainingSteps = BALL_STEPS_PER_MOVE - stepId;

//         if(remainingSteps == 1) {
//             newX = wantedX;
//             newY = wantedY;
//         } else {

//             int diffX = int(wantedX) - int(startX);
//             int diffY = int(wantedY) - int(startY);


//             if(diffX > 0){

//                 newX = startX + stepId* uint((1000 * diffX) / int(BALL_STEPS_PER_MOVE-1)) / 1000;
//             }else if (diffX < 0){

//                 newX = startX - stepId * uint((1000 * -diffX) / int(BALL_STEPS_PER_MOVE-1)) / 1000;
//             }

//             if(diffY > 0){
//                 newY  = startY + stepId * uint((1000 * diffY) / int(BALL_STEPS_PER_MOVE-1)) / 1000;
//             }else if (diffY < 0){
//                 newY  = startY - stepId * uint((1000 * -diffY) / int(BALL_STEPS_PER_MOVE-1) / 1000);
//             }
//         }

//         //interceptions
//         // if(move.state.team_with_the_ball == 2){
//         //     for(uint playerId = 0; playerId < 10; ++playerId){

//         //         uint dist = uint((int(newX) - int(move.state.team1_x_positions[playerId]))**2) + uint((int(newY) - int(move.state.team1_y_positions[playerId]))**2);

//         //         if(dist < MAX_BALL_DISTANCE_REQUIRED && false){
//         //             move.state.team_with_the_ball = 1;
//         //             move.state.interceptionOcurred = true;
//         //             move.state.player_id_with_the_ball = playerId;
//         //             break;
//         //         }
//         //     }
//         // } else{
//         //     for(uint playerId = 0; playerId < 10; ++playerId){
//         //         uint playerPosX = move.state.team2_x_positions[playerId];
//         //         uint playerPosY = move.state.team2_y_positions[playerId];

//         //         uint dist = uint((int(newX) - int(playerPosX))**2) + uint((int(newY) - int(playerPosY))**2);

//         //         if(dist < MAX_BALL_DISTANCE_REQUIRED && false){
//         //             move.state.team_with_the_ball = 2;
//         //             move.state.interceptionOcurred = true;
//         //             move.state.player_id_with_the_ball = playerId;
//         //             break;
//         //         }
//         //     }
//         // }
//     }


//     function _pointWithinTheField(uint x, uint y) internal view returns (bool) {
//         return x < FIELD_W && y < FIELD_H;
//     }

//     function _playerStatsAllowTheAdvancment(PlayerStats memory playerStats, uint diffX, uint diffY) internal view returns (bool) {
//         //TODO: ...
//         return true;
//     }
// }
