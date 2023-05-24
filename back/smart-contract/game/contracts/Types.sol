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
    }

    struct PlayerStats {
        uint speed;
        uint skill;
        uint stamina;
    }

    struct TeamState {
        PlayerStats[] playerStats;
        uint[] xPos;
        uint[] yPos;

        bool hasTheBall;
        uint playerIdWithTheBall;
    }

    struct TeamMove {
        bytes commitment;
        bytes reveal;

        uint[] xPos;
        uint[] yPos;

        bool wantToPass;
        uint receivingPlayerId;

        bool wantToShoot;
    }


    struct ProgressionState {
        bool ballWasWon;
        uint ballWasWonByTeam;

        bool interceptionOccured;
        uint interceptionAchievedByTeam;
        uint[] ballXPos;
        uint[] ballYPos;

        bool goalWasScored;
        uint goalWasScoredByTeam;

        TeamState[] teamState;
    }

}