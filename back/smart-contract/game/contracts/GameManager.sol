// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Constants.sol";
import "./Types.sol";
import "./GameLogic.sol";
import "./interfaces/IChainlinkFunctionConsumer.sol";


// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract GameManager {

    address public ticker;

    Constants public constants;

    GameLogic public logic;

    uint public matchCounter;
    mapping(uint => Types.MatchInfo) public matches;
    mapping(uint => uint) public matchIdToMoveId;
    mapping(uint => mapping(uint => Types.MoveInfo)) public matchProgression;

    mapping(uint => uint) matchIdToVRFRequestId;
    mapping(uint => uint) VRFRequestIdToFullfilmentValue;

    modifier matchNotFullyInitialized (uint matchId) {
        require(matches[matchId].initFinished == false, "ERR: The match has already been initialized!");
        _;
    }
    
    constructor() {
        constants = new Constants();
        logic = new GameLogic();

    }

    function commitments(uint matchId, uint moveId) public view returns (Types.CommitmentInfo[] memory) {
        return matchProgression[matchId][moveId].commitments;
    }
    function reveals(uint matchId, uint moveId) public view returns (Types.RevealInfo[] memory) {
        return matchProgression[matchId][moveId].reveals;
    }



    function createMatch(
        address team1_commitmentChainlinkFunctionConsumer, 
        address team1_revealChainlinkFunctionConsumer
    ) public {

        matches[matchCounter].team1_commitmentChainlinkFunctionConsumer = team1_commitmentChainlinkFunctionConsumer;
        matches[matchCounter].team1_revealChainlinkFunctionConsumer = team1_revealChainlinkFunctionConsumer;

        matchCounter += 1;

        //TODO:emit event
    }

    function joinMatch(
        uint matchId,
        address team2_commitmentChainlinkFunctionConsumer, 
        address team2_revealChainlinkFunctionConsumer
    ) public {

        require(matchCounter > matchId, "ERR: Match with that ID has not yet been created!");

        matches[matchId].team2_commitmentChainlinkFunctionConsumer = team2_commitmentChainlinkFunctionConsumer;
        matches[matchId].team2_revealChainlinkFunctionConsumer = team2_revealChainlinkFunctionConsumer;

        requestSeed(matchId);

        //TODO:emit event
    }

    function requestSeed(uint matchId) matchNotFullyInitialized(matchId) internal {

        //TODO: initiate VRF request...
        uint requestId = 1301;

        matchIdToVRFRequestId[matchId] = requestId;

        VRFRequestIdToFullfilmentValue[requestId] = 1301;
    }

    function completeInitialization(uint matchId) public matchNotFullyInitialized(matchId) {

        require(VRFRequestIdToFullfilmentValue[matchIdToVRFRequestId[matchId]] != 0, "ERR: Randomness has not been fullfiled for that match!");

        //TODO: generate random values for both teams player stats

        _initMoveInStorage(matchId, 0);
        matches[matchId].initFinished = true;
    }

    function commitmentTick(uint matchId) public {

        _initMoveInStorage(matchId, matchIdToMoveId[matchId]);

        require(matchCounter > matchId, "ERR: Match with that ID has not yet been created!");

        require(matches[matchId].initFinished == true, "ERR: The match is not fully initialized!");

        IChainlinkFunctionConsumer(matches[matchId].team1_commitmentChainlinkFunctionConsumer).requestData();

        IChainlinkFunctionConsumer(matches[matchId].team2_commitmentChainlinkFunctionConsumer).requestData();
    }

    function updateCommitmentInfo(uint matchId) public {

        require(matches[matchId].initFinished == true, "ERR: The match is not fully initialized!");

        require(IChainlinkFunctionConsumer(matches[matchId].team1_commitmentChainlinkFunctionConsumer).dataReady(), "ERR: Team1 Commitment not fullfiled!");

        require(IChainlinkFunctionConsumer(matches[matchId].team2_commitmentChainlinkFunctionConsumer).dataReady(), "ERR: Team2 Commitment not fullfiled!");

        uint moveId = matchIdToMoveId[matchId];
        matchProgression[matchId][moveId].commitments[0].data = 
            IChainlinkFunctionConsumer(matches[matchId].team1_commitmentChainlinkFunctionConsumer).copyData();

        matchProgression[matchId][moveId].commitments[1].data = 
            IChainlinkFunctionConsumer(matches[matchId].team2_commitmentChainlinkFunctionConsumer).copyData();
    }

    function revealTick(uint matchId) public {

        require(matches[matchId].initFinished == true, "ERR: The match is not fully initialized!");

        IChainlinkFunctionConsumer(matches[matchId].team1_revealChainlinkFunctionConsumer).requestData();

        IChainlinkFunctionConsumer(matches[matchId].team2_revealChainlinkFunctionConsumer).requestData();
    }

    function updateRevealInfo(uint matchId) public {
        require(matches[matchId].initFinished == true, "ERR: The match is not fully initialized!");

        require(IChainlinkFunctionConsumer(matches[matchId].team1_revealChainlinkFunctionConsumer).dataReady(), "ERR: Team1 Reveal not fullfiled!");

        require(IChainlinkFunctionConsumer(matches[matchId].team2_revealChainlinkFunctionConsumer).dataReady(), "ERR: Team2 Reveal not fullfiled!");

        bytes memory team1_revealData = IChainlinkFunctionConsumer(matches[matchId].team1_revealChainlinkFunctionConsumer).copyData();
        updateRevealForTeam(matchId, 1, team1_revealData);
            

        bytes memory team2_revealData = IChainlinkFunctionConsumer(matches[matchId].team2_revealChainlinkFunctionConsumer).copyData();
        updateRevealForTeam(matchId, 2, team2_revealData);
          
    }

    function getCommitment(bytes memory rawData) public view returns (bytes32) {
        return abi.decode(rawData, (bytes32));
    }

    function updateRevealForTeam(uint matchId, uint teamId, bytes memory rawData) public {

        uint moveId = matchIdToMoveId[matchId];
        
        Types.RevealInfo storage reveal = matchProgression[matchId][moveId].reveals[teamId - 1];

        reveal.data = rawData;

        //decoding
        uint8[10] memory rawData= abi.decode(rawData, (uint8[10]));

        reveal.team_x_positions = new uint[](10);
        for(uint i = 0; i < 10; ++i){
            reveal.team_x_positions[i] = rawData[i];
        }
    }

    function stateUpdate(uint matchId) public {


        (bool success, ) = address(logic).delegatecall(
            abi.encodeWithSignature("update(uint256)", matchId)
        );

        require(success, "ERR: Delegate call failed!");

        matchIdToMoveId[matchId] += 1;



    }


    function dispute() public {
        //TBD
    }

    function _initMoveInStorage(uint matchId, uint moveId) internal {
        Types.MoveInfo storage move = matchProgression[matchId][moveId];

        bytes memory b;
        Types.CommitmentInfo memory commitment1 = Types.CommitmentInfo(b); 
        Types.CommitmentInfo memory commitment2 = Types.CommitmentInfo(b); 

        move.commitments.push(commitment1);
        move.commitments.push(commitment2);

        Types.RevealInfo memory reveal1 = Types.RevealInfo(
            b,
            0,
            new uint[](1),
            new uint[](1),
            false,
            0,
            false
        );
        Types.RevealInfo memory reveal2 = Types.RevealInfo(
            b,
            0,
            new uint[](1),
            new uint[](1),
            false,
            0,
            false
        );
        move.reveals.push(reveal1);
        move.reveals.push(reveal2);


        for(uint i = 0; i < 2; ++i){
            move.reveals[i].team_x_positions = new uint[](10);
            move.reveals[i].team_y_positions = new uint[](10);
        }
        

        //TODO: find a fix around
        // move.state.team1_playerStats = new Types.PlayerStats[](10);
        // move.state.team2_playerStats = new Types.PlayerStats[](10);

        move.state.team1_x_positions = new uint[](10);
        move.state.team1_y_positions = new uint[](10);
        move.state.team2_x_positions = new uint[](10);
        move.state.team1_y_positions = new uint[](10);

        move.state.pass_ball_x_positions = new uint[](7);
        move.state.pass_ball_y_positions = new uint[](7);
   
    }
    

}
