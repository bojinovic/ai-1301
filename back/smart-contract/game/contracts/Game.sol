// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Game {

    uint constant STEPS_IN_A_MOVE = 5;
    uint constant FIELD_W = 100;
    uint constant FIELD_H = 50;

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

        uint[10] team1_x_positions;
        uint[10] team2_x_positions;
        uint[10] team1_y_positions;
        uint[10] team2_y_positions;

        uint team1_seed;
        uint team2_seed;

        uint team_with_the_ball;
        uint player_id_with_the_ball;
    }

    uint public matchCounter;
    mapping(uint => MatchInfo) public matches;
    mapping(uint => uint) public matchIdToMoveId;
    mapping(uint => mapping(uint => MoveInfo)) public matchProgression;
    
    constructor() {

        matchProgression[matchCounter][0].team1_x_positions = [10, 20 ,30, 11, 14, 15, 16, 12, 17, 11];
        matchProgression[matchCounter][0].team1_y_positions = [10, 20 ,30, 11, 3, 15, 16, 12, 17, 11];


        matchProgression[matchCounter][0].team2_x_positions = [10, 20 ,2, 11, 4, 15, 9, 12, 17, 11];
        matchProgression[matchCounter][0].team2_y_positions = [10, 30 ,30, 11, 14, 1, 16, 12, 1, 11];


        matchProgression[matchCounter][1].team1_x_positions = [1, 4 ,30, 5, 14, 1, 16, 12, 17, 11];
        matchProgression[matchCounter][1].team1_y_positions = [10, 5 ,30, 2, 3, 15, 5, 12, 17, 11];


        matchProgression[matchCounter][1].team2_x_positions = [10, 20 ,2, 1, 14, 15, 9, 12, 17, 33];
        matchProgression[matchCounter][1].team2_y_positions = [1, 30 ,1, 11, 14, 1, 3, 12, 12, 11];

        matchCounter += 1;
    }

    function createMatch() public {}

    function joinMatch() public {}

    function commitmentTick() public {}

    function updateCommitmentInfo(uint matchId, bytes memory commitment) public {}

    function revealTick() public {}

    function updateRevealInfo(uint matchId, bytes memory commitment) public {}

    function stateUpdateTick(uint matchId, MoveInfo memory reportedMoveInfo) public {
        matchProgression[ matchId][ matchIdToMoveId[matchId] ].team1_x_positions = reportedMoveInfo.team1_x_positions;
        matchProgression[ matchId][ matchIdToMoveId[matchId] ].team2_x_positions = reportedMoveInfo.team2_x_positions;

        matchProgression[ matchId][ matchIdToMoveId[matchId] ].team1_y_positions = reportedMoveInfo.team1_y_positions;
        matchProgression[ matchId][ matchIdToMoveId[matchId] ].team2_y_positions = reportedMoveInfo.team2_y_positions;

        matchProgression[ matchId][ matchIdToMoveId[matchId] ].team_with_the_ball = reportedMoveInfo.team_with_the_ball;
        matchProgression[ matchId][ matchIdToMoveId[matchId] ].player_id_with_the_ball = reportedMoveInfo.player_id_with_the_ball;

    }


    function dispute() public {

    }


    function playout(uint matchId, uint previousMoveId) public view returns (MoveInfo memory move) {

        MoveInfo memory previousMove = matchProgression[matchId][previousMoveId];
        MoveInfo memory currMove = matchProgression[matchId][previousMoveId+1];

        for(uint remainingSteps = STEPS_IN_A_MOVE; remainingSteps > 0; remainingSteps--){
            for(uint playerId = 0; playerId < 10; ++playerId){
                uint wantedX = currMove.team1_x_positions[playerId];
                uint wantedY = currMove.team1_y_positions[playerId];
                (uint playerPosX, uint playerPosY) = _advancePlayerPosition(matchId, 1, playerId, wantedX, wantedY, remainingSteps);
                
                move.team1_x_positions[playerId] = playerPosX;
                move.team1_y_positions[playerId] = playerPosY;
            }
        }
    }

    function _advancePlayerPosition(uint matchId, uint teamId, uint playerId, uint wantedX, uint wantedY, uint remainingSteps) internal view returns (uint newX, uint newY) {
        //TODO: requires... check if the move is possible at all

        uint currX = matchProgression[matchId][matchIdToMoveId[matchId]].team1_x_positions[playerId];
        uint currY = matchProgression[matchId][matchIdToMoveId[matchId]].team1_y_positions[playerId];

        if(remainingSteps == 0 
            || _pointWithinTheField(wantedX, wantedY) == false){

            return (currX, currY);
        }

        if(teamId == 2){
            currX = matchProgression[matchId][matchIdToMoveId[matchId]].team2_x_positions[playerId];
            currY = matchProgression[matchId][matchIdToMoveId[matchId]].team2_y_positions[playerId];
        }

        int diffX = int(wantedX) - int(currX);
        int diffY = int(wantedY) - int(currY);

        // console.log("wantedX : %s :: currX : %s", wantedX, currX);
        if(diffX > 0){

            newX = currX + uint((1000 * diffX) / int(remainingSteps)) / 1000;
        }else if (diffX < 0){

            newX = currX - uint((1000 * -diffX) / int(remainingSteps)) / 1000;
        }

        if(diffY > 0){
            newY = currY + uint((1000 * diffY) / int(remainingSteps)) / 1000;
        }else if (diffX < 0){
            newY = currY - uint((1000 * -diffY) / int(remainingSteps) / 1000);
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
