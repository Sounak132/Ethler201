var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var playerAddress;
var blockNumber;

$(document).ready(function(){
    window.ethereum.enable().then(function(accounts){
      let contractAddress = "0x2Bb4E36450667bdB36DC9dFD8bb23d19C7a31D9e";
      contractInstance = new web3.eth.Contract(abi, contractAddress, {from: accounts[0]});
      console.log(contractInstance);
      playerAddress = accounts[0];
    });

    $("#Gamble").click(gamble);
    $("#userBalanceBtn").click(showBalance);
    $("#userBalanceWithdraw").click(withdrawUser);
    $("#Withdraw").click(withdraw);
});

function gamble(e){
  e.preventDefault();
  let bet = parseFloat($("#bet").val());
  let unit = parseInt($("#unit").val());
  if(unit==0)unit = 1000000000000000000; //10^18
  bet*= unit;
  if(!isNaN(bet)){
    if(bet>2000000000000000000 ) alert("you can't gamble more than 2 ether");
    else if(bet<100000000000000) alert("you have to put at least 0.0001 ether");
    else {
      let input = parseInt($("#Input").val());
      config = {
        value: bet,
        gas: 6000000
      };
      contractInstance.methods.Play(input).send(config).
      then(function(){
        // console.log("Waiting...");
        $("#Output").text("Please Wait...");
        web3.eth.getBlockNumber()
        .then((res)=>{
          blockNumber = res;
          contractInstance.events.statusOfCalledBackPlayer(
            { filter: {User: playerAddress},
              fromBlock: blockNumber,
              toBlock: 'latest'},
            (error, data)=>{
            console.log(data, typeof data);
            var win = data.returnValues.status;
            getFront(win);
          });
        });
      });
    }
  }
}

function showBalance(e){
  // e.preventDefault();
  contractInstance.methods.showBalance().call().then((balance)=>{
    $("#userBalance").text(balance/1000000000000000000 + " eth");
  })
}

function withdrawUser(e){
  // e.preventDefault();
  contractInstance.methods.withdrawBalance().send()
  .then((confirmationNr)=>{
    alert("Your Transaction has been initiated!");
    // alert("Block confirmation number is", confirmationNr);
    showBalance();
  })
}

function withdraw(e){
  // e.preventDefault();
  contractInstance.methods.withdrawAll().send();
}

function getFront(win){
  // alert(win);
  if(win==true){
    $("#Output").text("YOU HAVE WON! CONGO!");
  }
  else {
    $("#Output").text("Sorry! You have lost! Why don't you give it anotherr try!");
  }
}
