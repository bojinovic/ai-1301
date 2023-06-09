// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";
// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IChainlinkFunctionConsumer.sol";

/**
 * @title Functions Consumer contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner, IChainlinkFunctionConsumer{
  using Functions for Functions.Request;
  using Counters for Counters.Counter;
  
  Counters.Counter private _tokenIdCounter;
  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;
  uint256 public SxTId;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);
  event SxTNFT(string name, uint256 id);
  event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  // https://github.com/protofire/solhint/issues/242
  // solhint-disable-next-line no-empty-blocks
  // constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {}
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) /*ERC721("Space & Time dNFT", "SXT-DNFT")*/ {
    // _safeMint(msg.sender, 0);
  }

  /**
   * @notice Send a simple request
   *
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param gasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function executeRequest(
    string memory source,
    bytes memory secrets,
    string[] memory args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public returns (bytes32) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) {
      req.addRemoteSecrets(secrets);
    }
    if (args.length > 0) req.addArgs(args);

    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    latestResponse = response;
    latestError = err;
    dataRead1y = true;
    emit OCRResponse(requestId, response, err);
    SxTId = abi.decode(response, (uint256));
    emit BatchMetadataUpdate(0, type(uint256).max);
  }
  

  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  function addSimulatedRequestId(address oracleAddress, bytes32 requestId) public onlyOwner {
    addExternalRequest(oracleAddress, requestId);
  }

  string public _source;
  bytes public _secrets;
  string[] public _args;
  uint64 public _subId;
  uint32 public _gasLimit;

  function setMetadata(
    string memory source,
    bytes memory secrets,
    string[] memory args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public {
    _source = source;
    _secrets = secrets;
    for(uint i = 0; i < args.length; ++i){
      _args.push(args[i]);
    }
    _subId = subscriptionId;
    _gasLimit = gasLimit;
  }

    bool public dataHasBeenRead1 = true;
    bool public dataRead1y;

    function dataHasBeenRead() public override view returns (bool) {return dataHasBeenRead1;}
    function dataIsReady() public override view returns (bool){return dataRead1y;}

    function requestData () override public {

      require(dataHasBeenRead() == true, "ERR: Previous data has not been read!");

      string[] memory arr = new string[](2);
      for(uint i = 0; i < _args.length; ++i){
        arr[i] = _args[i];
      }
      executeRequest(
       _source,
        "", 
        arr, _subId, _gasLimit);
    }

    function copyData () public override returns (bytes memory){

      require(dataIsReady() == true, "ERR: Request has not yet been fullfiled!");

      dataHasBeenRead1 = true;

      return latestResponse;
    }

}
