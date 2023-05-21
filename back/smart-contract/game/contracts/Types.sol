pragma solidity ^0.8.18;

contract Types {


    address public ticker;

    struct PlayerStats {
        uint speed;
        uint skill;
        uint stamina;
    }

    enum MATCH_STATE {DUMMY, INIT_PHASE, COMMITMENT_PHASE, REVEAL_PHASE, STATE_UPDATE_PHASE}

    struct MatchInfo {
        uint seed;

        PlayerStats[] team1_playerStats;
        PlayerStats[] team2_playerStats;

        address team1_commitmentChainlinkFunctionConsumer;
        address team2_commitmentChainlinkFunctionConsumer;

        address team1_revealChainlinkFunctionConsumer;
        address team2_revealChainlinkFunctionConsumer;

        bool initFinished;
    }

    struct CommitmentInfo {
        bytes data;
    }

    struct RevealInfo {

        bytes data;
        
        uint seed;
        uint[] team_x_positions;
        uint[] team_y_positions;
        
        bool wants_to_pass;
        uint receiving_player_id;

        bool wants_to_shoot;
    }

    struct StateInfo {
        PlayerStats[] team1_playerStats;
        PlayerStats[] team2_playerStats;

        uint[] team1_x_positions;
        uint[] team2_x_positions;
        uint[] team1_y_positions;
        uint[] team2_y_positions;

        uint team_with_the_ball;
        uint player_id_with_the_ball;

        bool pass;
        uint receiving_player_id;
        bool interceptionOcurred;
        uint[] pass_ball_x_positions;
        uint[] pass_ball_y_positions;
        
        bool shoot;
    }

    struct MoveInfo {
        CommitmentInfo[] commitments;
        RevealInfo[] reveals;

        StateInfo state;
    }
}