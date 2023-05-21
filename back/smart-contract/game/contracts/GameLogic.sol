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

    ) public view returns (
        Types.MoveInfo memory nextMove,
        Types.MoveInfo[] memory progression 
    ) {
        uint currMoveId = matchIdToMoveId[matchId];
        uint nextMoveId = currMoveId + 1;

        Types.MoveInfo memory currMove =_copyMoveFromStorage(matchId, currMoveId);

        nextMove = _copyMoveFromStorage(matchId, nextMoveId);

        //create progression stage
        progression = new Types.MoveInfo[](5);
        // for(uint i = 0; i < 5; ++i){ 
        //     progression[i] = _createNewMove(); 
        //     progression[i] = _copyMoveFromMemory(nextMove);

        // }
        // progression[0] = _copyMoveFromMemory(currMove);


        for(uint stepId = 1; stepId <= constants.PLAYER_STEPS_PER_MOVE(); ++stepId){

            for(uint teamId = 1; teamId < 3; ++teamId){

                //advance team positions
                for(uint playerId = 0; playerId < 10; ++playerId){

                    _advancePlayerPosition(currMove, nextMove, teamId, playerId, stepId);
                    
                }
            }

            progression[stepId - 1] = _copyMoveFromMemory(nextMove);

        }


        console.log("nextMove[] %s", nextMove.state.team1_x_positions[0]);
        console.log("progression[] %s", progression[2].state.team1_x_positions[0]);

        nextMove.state.shoot = !currMove.state.shoot;
    }

    function _createNewMove() internal view returns (Types.MoveInfo memory newMove) {
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



    function _copyMoveFromStorage(uint matchId, uint moveId) internal view returns (Types.MoveInfo memory dst) {
        Types.MoveInfo storage src = matchProgression[matchId][moveId];
        dst = _createNewMove();
        for(uint i = 0; i < 10; ++i){
            for(uint j = 0; j < 2; ++j){
                dst.reveals[j].team_x_positions[i] = src.reveals[j].team_x_positions[i];
                dst.reveals[j].team_y_positions[i] = src.reveals[j].team_y_positions[i];
            }
            dst.state.team1_x_positions[i] = src.state.team1_x_positions[i];
            dst.state.team1_y_positions[i] = src.state.team1_y_positions[i];
            dst.state.team2_x_positions[i] = src.state.team2_x_positions[i];
            dst.state.team2_y_positions[i] = src.state.team2_y_positions[i];
        }
    }

    function _pasteToStorage(uint matchId, uint moveId) internal returns (Types.MoveInfo memory dst) {
        Types.MoveInfo storage src = matchProgression[matchId][moveId];
        dst = _createNewMove();
        for(uint i = 0; i < 10; ++i){
            for(uint j = 0; j < 2; ++j){
                dst.reveals[j].team_x_positions[i] = src.reveals[j].team_x_positions[i];
                dst.reveals[j].team_y_positions[i] = src.reveals[j].team_y_positions[i];
            }
            dst.state.team1_x_positions[i] = src.state.team1_x_positions[i];
            dst.state.team1_y_positions[i] = src.state.team1_y_positions[i];
            dst.state.team2_x_positions[i] = src.state.team2_x_positions[i];
            dst.state.team2_y_positions[i] = src.state.team2_y_positions[i];
        }
    }


    function _copyMoveFromMemory(Types.MoveInfo memory src) internal view returns (Types.MoveInfo memory dst) {
        dst = _createNewMove();
        for(uint i = 0; i < 10; ++i){
            for(uint j = 0; j < 2; ++j){
                dst.reveals[j].team_x_positions[i] = src.reveals[j].team_x_positions[i];
                dst.reveals[j].team_y_positions[i] = src.reveals[j].team_y_positions[i];
            }
            dst.state.team1_x_positions[i] = src.state.team1_x_positions[i];
            dst.state.team1_y_positions[i] = src.state.team1_y_positions[i];
            dst.state.team2_x_positions[i] = src.state.team2_x_positions[i];
            dst.state.team2_y_positions[i] = src.state.team2_y_positions[i];
        }
    }

    function _copyPositions(Types.MoveInfo memory dst, Types.MoveInfo memory src) internal view returns (Types.MoveInfo memory) {
        for(uint i = 0; i < 10; ++i){
            dst.state.team1_x_positions[i] = src.state.team1_x_positions[i];
            dst.state.team1_y_positions[i] = src.state.team1_y_positions[i];
            dst.state.team2_x_positions[i] = src.state.team2_x_positions[i];
            dst.state.team2_y_positions[i] = src.state.team2_y_positions[i];
        }

        return dst;
    }

    function _advancePlayerPosition(Types.MoveInfo memory currMove, Types.MoveInfo memory nextMove, uint teamId, uint playerId, uint stepId) internal view {
        //where the player ultimately wants to go
        uint wantedX = currMove.reveals[teamId-1].team_x_positions[playerId];
        uint wantedY = currMove.reveals[teamId-1].team_y_positions[playerId];

        uint currX; uint currY;

        if(teamId == 1){

            currX = nextMove.state.team1_x_positions[playerId];
            currY = nextMove.state.team1_y_positions[playerId];

            console.log("wantedX ::: %s", wantedX);
            console.log("currX ::: %s", currX);

            if(currX == wantedX && wantedX == currY){

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


        if(teamId == 1){
            nextMove.state.team1_x_positions[playerId] = newX;
            nextMove.state.team1_y_positions[playerId] = newY;
        } else {
            nextMove.state.team2_x_positions[playerId] = newX;
            nextMove.state.team2_y_positions[playerId] = newY;
        }
    }



}
