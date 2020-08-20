pragma solidity 0.5.12;

contract Ownable {
    address public owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier Owned() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    constructor() public {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }
    function changeOwner(address newOwner)public Owned {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    function getOwner() external view returns (address) {
        return owner;
    }
}
