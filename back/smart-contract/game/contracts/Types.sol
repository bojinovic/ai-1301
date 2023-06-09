pragma solidity ^0.8.18;

contract Types {

    enum MATCH_STAGE {
        DUMMY,
        P1_CREATED_THE_MATCH,
        P2_JOINED_THE_MATCH,
        RANDOM_SEED_FETCHED,
        RANDOM_SEED_RECEIVED,
        COMMITMENTS_FETCHED,
        COMMITMENTS_RECEIVED,
        REVEALS_FETCHED,
        REVEAL_RECEIVED,
        STATE_UPDATE_FETCHED,
        STATE_UPDATE_PERFORMED,
        MATCH_ENDED
    }


    struct MatchInfo {
        uint seed;

        address[] commitmentFunctionConsumer;
        address[] revealFunctionConsumer;

        MATCH_STAGE stage;

        uint stateId;
    }


    struct MatchState {
        uint[] score;

        uint teamIdWithTheBall;
        uint playerIdWithTheBall;

        uint ballXPos;
        uint ballYPos;

        bool shotWasTaken;
        bool goalWasScored;

        bytes reportedState;
    }

    struct PlayerStats {
        uint speed;
        uint skill;
        uint stamina;
    }

    struct TeamState {
        PlayerStats[] playerStats;
        PlayerStats goalKeeperStats;
        uint[] xPos;
        uint[] yPos;
    }

    struct TeamMove {
        bytes commitment;
        bytes reveal;

        uint seed;

        uint[] xPos;
        uint[] yPos;

        bool wantToPass;
        uint receivingPlayerId;

        bool wantToShoot;
    }

    struct ProgressionState {
        uint startingTeamIdWithTheBall;
        uint startingPlayerIdWithTheBall;

        uint teamIdWithTheBall;
        uint playerIdWithTheBall;

        bool ballWasWon;
        uint ballWasWonByTeam;

        bool interceptionOccured;
        uint interceptionAchievedByTeam;
        uint ballXPos;
        uint ballYPos;

        bool shotWasTaken;
        uint teamIdOfTheGoalWhereTheShootWasTaken;
        bool goalWasScored;
        uint goalWasScoredByTeam;

        TeamState[] teamState;
    }

}