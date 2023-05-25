// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../interfaces/IChainlinkFunctionConsumer.sol";

contract RevealChainlinkFunctionConsumer is IChainlinkFunctionConsumer{

    bytes encodedData;
    bytes32 commitment;
    bool public dataIsReady = false;
    bool public dataHasBeenRead = true;
  
    constructor () {
      updateData(123);
    }
    function requestData () external{
      require(dataHasBeenRead == true, "ERR: Previous data has not been read!");
      dataIsReady = true;
      dataHasBeenRead = false;
    }

    function copyData () external returns (bytes memory){
      dataHasBeenRead = true;
      dataIsReady = false;
      return encodedData;
    }
    function updateData (uint seed) public {

      uint data = seed;

      encodedData = abi.encode(seed, data);

      commitment = keccak256(encodedData);
    }
}