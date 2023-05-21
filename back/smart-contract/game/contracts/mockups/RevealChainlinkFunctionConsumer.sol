// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../interfaces/IChainlinkFunctionConsumer.sol";

contract RevealChainlinkFunctionConsumer is IChainlinkFunctionConsumer{

    bytes encodedData;
    bytes32 commitment;
    bool public dataReady = false;
    bool public dataHasBeenRead = true;
  
    constructor () {
      updateData(123);
    }
    function requestData () external{
      require(dataHasBeenRead == true, "ERR: Previous data has not been read!");
      dataReady = true;
      dataHasBeenRead = false;
    }

    function copyData () external returns (bytes memory){
      dataHasBeenRead = true;
      dataReady = false;
      return encodedData;
    }

    function updateData (uint seed) public {

      uint8[10] memory data = [uint8(seed % 7), uint8(seed % 71), uint8(seed % 17), uint8(seed % 13), uint8(seed % 51), uint8(seed % 12), uint8(seed % 57), uint8(seed % 51), uint8(seed % 42), uint8(seed % 19)];

      encodedData = abi.encode(data);

      commitment = keccak256(encodedData);
    }
}