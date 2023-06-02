// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "../Types.sol";
interface IGame {

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
        uint[] team2_x_positions;
        uint[] team1_y_positions;
        uint[] team2_y_positions;

        uint team1_seed;
        uint team2_seed;

        uint team_with_the_ball;
        uint player_id_with_the_ball;

        bool pass;
        uint[] pass_ball_x_positions;
        uint[] pass_ball_y_positions;
        uint receiving_player_id;
        bool interceptionOcurred;

        bool shoot;
    }


    function createMatch() external;

    function joinMatch() external ;

    function commitmentTick() external ;

    function updateCommitmentInfo(uint matchId, bytes memory commitment) external ;

    function revealTick() external ;

    function updateRevealInfo(uint matchId, bytes memory commitment) external ;

    function stateUpdateTick(uint matchId, MoveInfo memory reportedMoveInfo) external ;

    function dispute() external;

    function playout(uint matchId, uint previousMoveId) external view returns (MoveInfo memory move, MoveInfo[5] memory moveProgression) ;

    function getProgression(uint matchId, uint stateId) external view returns (
        Types.ProgressionState[] memory progression
    );

}
