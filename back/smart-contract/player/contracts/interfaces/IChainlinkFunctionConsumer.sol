// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IChainlinkFunctionConsumer {

    function dataIsReady() external view returns(bool);

    function dataHasBeenRead() external view returns(bool);


    function requestData () external;

    function copyData () external returns (bytes memory);
}
