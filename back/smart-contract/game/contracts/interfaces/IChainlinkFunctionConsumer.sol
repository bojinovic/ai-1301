// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Additional interface for all Function Consumers in the AI:1301 project
/// @author Milos Bojinovic
/// @notice Experimental use
interface IChainlinkFunctionConsumer {

    /// @notice Method that makes a Request to be processed by Chainlink Decentralized Oracle Network (DON)
    function requestData () external;

    /// @notice Method extracts the Request Data and updates its status
    /// @return Received Data after the Request
    function copyData () external returns (bytes memory);

    /// @notice Method that checks whether the Request has been fulfilled
    /// @return Status of the Request fulfillment
    function dataIsReady () external view returns(bool);

    /// @notice Method that checks whether the Request Data has been used
    /// @return Status of the Request Data use
    function dataHasBeenRead () external view returns(bool);
}
