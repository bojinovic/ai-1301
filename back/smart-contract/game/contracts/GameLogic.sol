// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Constants.sol";
import "./Types.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
import "hardhat/console.sol";

contract GameLogic {

    address public ticker;

    Constants public constants;

    GameLogic public logic;

    uint public matchCounter;
    mapping(uint => Types.MatchInfo) public matches;
    mapping(uint => uint) public matchIdToMoveId;
    mapping(uint => mapping(uint => Types.MoveInfo)) public matchProgression;

    mapping(uint => uint) matchIdToVRFRequestId;
    mapping(uint => uint) VRFRequestIdToFullfilmentValue;

    
    constructor() {
      
    }

    function update(

        uint matchId

    ) public {
        uint currMoveId = matchIdToMoveId[matchId];
        uint nextMoveId = currMoveId + 1;

        Types.MoveInfo memory currMove =_copyMoveFromStorage(matchId, currMoveId);

        Types.MoveInfo memory nextMove = _copyMoveFromStorage(matchId, nextMoveId);

        for(uint stepId = 1; stepId <= constants.PLAYER_STEPS_PER_MOVE(); ++stepId){
            

            //advance team1 positions
            for(uint playerId = 0; playerId < 10; ++playerId){


                _advancePlayerPosition(currMove, nextMove, 1, playerId, stepId);
                
            }
            //advance team2 positions
            for(uint playerId = 0; playerId < 10; ++playerId){

            }
        }








        nextMove.state.shoot = !currMove.state.shoot;

    }

    function createNewMove() internal returns (Types.MoveInfo memory newMove) {
        bytes memory b;
        Types.CommitmentInfo memory commitment1 = Types.CommitmentInfo(b); 
        Types.CommitmentInfo memory commitment2 = Types.CommitmentInfo(b); 

        newMove.commitments = new Types.CommitmentInfo[](2);
        newMove.commitments[0] = commitment1;
        newMove.commitments[1] = commitment2;
        
        Types.RevealInfo memory reveal1 = Types.RevealInfo(
            b,
            0,
            new uint[](1),
            new uint[](1),
            false,
            0,
            false
        );
        Types.RevealInfo memory reveal2 = Types.RevealInfo(
            b,
            0,
            new uint[](1),
            new uint[](1),
            false,
            0,
            false
        );

        newMove.reveals = new Types.RevealInfo[](2);
        newMove.reveals[0] = reveal1;
        newMove.reveals[1] = reveal2;
        for(uint i = 0; i < 2; ++i){
            newMove.reveals[i].team_x_positions = new uint[](10);
            newMove.reveals[i].team_y_positions = new uint[](10);
        }

        newMove.state.team1_playerStats = new Types.PlayerStats[](10);
        newMove.state.team2_playerStats = new Types.PlayerStats[](10);

        newMove.state.team1_x_positions = new uint[](10);
        newMove.state.team1_y_positions = new uint[](10);
        newMove.state.team2_x_positions = new uint[](10);
        newMove.state.team2_y_positions = new uint[](10);

        newMove.state.pass_ball_x_positions = new uint[](7);
        newMove.state.pass_ball_y_positions = new uint[](7);
    }



    function _copyMoveFromStorage(uint matchId, uint moveId) internal returns (Types.MoveInfo memory newMove) {
        newMove = createNewMove();
        for(uint i = 0; i < 10; ++i){
            newMove.state.team1_x_positions[i] = matchProgression[matchId][moveId].state.team1_x_positions[i];
            newMove.state.team1_y_positions[i] = matchProgression[matchId][moveId].state.team1_y_positions[i];
        }
    }

    function _advancePlayerPosition(Types.MoveInfo memory currMove, Types.MoveInfo memory nextMove, uint teamId, uint playerId, uint stepId) internal {
        //where the player ultimately wants to go
        uint wantedX = currMove.reveals[teamId-1].team_x_positions[playerId];
        uint wantedY = currMove.reveals[teamId-1].team_y_positions[playerId];
        console.log("XXXXX");

        uint currX; uint currY;

        if(teamId == 1){

            currX = nextMove.state.team1_x_positions[playerId];
            currY = nextMove.state.team1_y_positions[playerId];

            if(currX == wantedX && wantedX == currY){
                console.log("123123123");

                return;
            }
            
            if(stepId == constants.PLAYER_STEPS_PER_MOVE()){
                nextMove.state.team1_x_positions[playerId] = wantedX;
                nextMove.state.team1_y_positions[playerId] = wantedY;
                return;
            } 
        } else {
            currX = nextMove.state.team2_x_positions[playerId];
            currY = nextMove.state.team2_y_positions[playerId];

            if(currX == wantedX && wantedX == currY){
                return;
            }
            
            if(stepId == constants.PLAYER_STEPS_PER_MOVE()){
                nextMove.state.team2_x_positions[playerId] = wantedX;
                nextMove.state.team2_y_positions[playerId] = wantedY;
                return;
            } 
        }

        console.log("asdasdasdd");


        uint newX; uint newY;

        int diffX = int(wantedX) - int(currX);
        int diffY = int(wantedY) - int(currY);

        if(diffX > 0){
            newX = currX + uint((1000 * diffX) / int(constants.PLAYER_STEPS_PER_MOVE())) / 1000;
        }else if (diffX < 0){
            newX = currX - uint((1000 * -diffX) / int(constants.PLAYER_STEPS_PER_MOVE())) / 1000;

        }else{
            newX = wantedX;
        }

        if(diffY > 0){
            newY = currY + uint((1000 * diffY) / int(constants.PLAYER_STEPS_PER_MOVE())) / 1000;
        }else if (diffY < 0){
            newY = currY - uint((1000 * -diffY) / int(constants.PLAYER_STEPS_PER_MOVE()) / 1000);
        }else{
            newY = wantedY;
        }

        console.log("t1 X: %s", newX);


        if(teamId == 1){
            nextMove.state.team1_x_positions[playerId] = newX;
            nextMove.state.team1_y_positions[playerId] = newY;
        } else {
            nextMove.state.team2_x_positions[playerId] = newX;
            nextMove.state.team2_y_positions[playerId] = newY;
        }
    }



}
