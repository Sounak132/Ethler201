pragma solidity 0.5.12;

import "./Ownable.sol";
import "./provableAPI.sol";

contract Ethler is Ownable, usingProvable{

    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
    uint contractBalance;

    // uint256 public latestNumber;
    struct Bet{
      address Player;
      uint value;
      uint choice;
    }

    mapping (bytes32 => Bet) public waiting;
    mapping (address => uint) public BalanceSheet;
    mapping (address => bool) public waitingStatus;

    modifier costs(uint value){
      require(msg.value >= value);
      _;
    }

    event statusOfCalledBackPlayer(address indexed Player, bool status);

// part  of callback function
    function updatePlayerBalance(address Player, uint bet)private {
        BalanceSheet[Player] += bet*2;
        contractBalance -= bet;
    }

    constructor()public{
      provable_setProof(proofType_Ledger);
      Play(1);  //this function reqires ether, but we are not sending any
    }

// function after the flip button
    function Play(uint Input)payable public costs(0.001 ether){
      require(waitingStatus[msg.sender] == false, "You are already in a game");
      require(Input == 0 || Input == 1, "Input was not valid");

      // updating player status
      waitingStatus[msg.sender] = true;

      Bet memory newbet;
      newbet.Player = msg.sender;
      newbet.value = msg.value;
      newbet.choice = Input;

      // update contract balance
      contractBalance += msg.value;
      uint256 QUERY_EXECUTION_DELAY = 0;
      uint256 GAS_FOR_CALLBACK = 200000;

      bytes32 queryId = provable_newRandomDSQuery(
          QUERY_EXECUTION_DELAY,
          NUM_RANDOM_BYTES_REQUESTED,
          GAS_FOR_CALLBACK
      );

      waiting[queryId] = newbet;
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public{
        require(msg.sender == provable_cbAddress());
        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof)!= 0) {/*doing nothing*/}
        else {
          uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;

           // theWaitingPlyer = waiting[_queryId];

          // retrieving data from struct

          bool status = waiting[_queryId].choice == randomNumber;
          address waitingPlayerAddress = waiting[_queryId].Player;
          uint val = waiting[_queryId].value;

          // in case of win update the BalanceSheet
          if(status) updatePlayerBalance(waitingPlayerAddress, val);

          // updating status of the player
          waitingStatus[waitingPlayerAddress] = false;
          delete waiting[_queryId];
          //emitting event
          emit statusOfCalledBackPlayer(waitingPlayerAddress, status);
        }
    }

// Your balance button
    function showBalance() public view returns(uint){
      return BalanceSheet[msg.sender];
    }

// withdraw button
    function withdrawBalance() public payable{
      uint toTransfer = BalanceSheet[msg.sender];
      require(toTransfer >= 100000000000000);
      BalanceSheet[msg.sender] = 0;
      msg.sender.transfer(toTransfer);
    }

// for owner to withdraw the smart contract funds
    function withdrawAll()public isOwned {
      uint toTransfer = address(this).balance;
      contractBalance -= toTransfer;
      msg.sender.transfer(toTransfer);
    }
// for cash deposition by the owner
    function Deosit()public isOwned payable costs(1 ether){
      contractBalance+= msg.value;
    }
}
