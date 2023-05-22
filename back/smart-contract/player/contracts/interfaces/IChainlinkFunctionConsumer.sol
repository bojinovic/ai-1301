// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IChainlinkFunctionConsumer {

    function dataReady() external view returns(bool);

    function dataHasBeenRead() external view returns(bool);


    function requestData () external;

    function copyData () external returns (bytes memory);
}
