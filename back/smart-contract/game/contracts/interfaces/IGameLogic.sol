// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Interface for the Main Game contract
/// @author Milos Bojinovic
/// @notice Experimental use

import "../Types.sol";
interface IGameLogic {

    /// @notice Sets the address of the Space and Time (SxT) Function Consumer
    /// @dev This Function consumer should implement IChainlinkFunctionConsumer interface
    /// @param sxt Address of the deployed SxT Function Consumer
    function setSxT(address sxt) external;


    /// @notice Creates a new match and registers the corresponding Function Consumers
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param team1_commitmentChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param team1_revealChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function createMatch(
        address team1_commitmentChainlinkFunctionConsumer, 
        address team1_revealChainlinkFunctionConsumer
    ) external;

    /// @notice Joins an already existing Match
    /// @dev Both Function consumers should implement IChainlinkFunctionConsumer interface
    /// @param matchId ID of the Match the User wants to join
    /// @param team2_commitmentChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Commitment Stage
    /// @param team2_revealChainlinkFunctionConsumer Address of the deployed Function Consumer 
    ///     that will be used in the Reveal Stage
    function joinMatch(
        uint matchId,
        address team2_commitmentChainlinkFunctionConsumer, 
        address team2_revealChainlinkFunctionConsumer
    ) external;

    /// @notice Initiates the start of Commitment Stage
    /// @dev Calls Commitment Function Consumers for both teams
    /// @param matchId ID of the Match
    function commitmentTick(uint matchId) external;

    /// @notice Ends the Commitment Stage and copies the underlying data
    /// @dev Request for both Commitments has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateCommitmentInfo(uint matchId) external;

    /// @notice Initiates the start of Reveal Stage
    /// @dev Calls Reveal Function Consumers for both teams
    /// @param matchId ID of the Match
    function revealTick(uint matchId) external;

    /// @notice Ends the Reveal Stage and copies the underlying data
    /// @dev Request for both Reveal has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateRevealInfo(uint matchId) external;

    /// @notice Initiates the start of State Update Stage
    /// @dev Calls SxT Function Consumer
    /// @param matchId ID of the Match
    function stateUpdateTick(uint matchId) external;

    /// @notice Ends the State Update Stage and unpacks the received data
    /// @dev Request for State Update has to be resolved (fulfilled)
    /// @param matchId ID of the Match
    function updateStateUpdateInfo(uint matchId) external;

    /// @notice On-chain execution of the State transition
    /// @dev Used when there's no reporting by SxT because costs a hell of gas :)
    /// @param matchId ID of the Match
    function stateUpdate(uint matchId) external;

    /// @notice Checks whether the reported State is correct
    /// @dev If the dispute is justified and there's a discrepancy the game is completly halted
    /// @param matchId ID of the Match
    /// @param stateId ID of the State after which there's a discrepancy
    function dispute(uint matchId, uint stateId) external;

    /// @notice Generates the next Match State and all of the States in between
    /// @dev Used by .stateUpdate and .dispute
    /// @param matchId ID of the Match
    /// @param stateId ID of the previous State
    /// @return progression A series of intermediate (and final) states
    function getProgression(
        uint matchId,
        uint stateId
    ) external returns (
        Types.ProgressionState[] memory progression
    );
}
