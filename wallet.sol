pragma solidity ^0.6.0;

contract wallet{
    address public owner;
    //pause will be a boolean as when set to true, no action can be performed
    bool public pause;
    constructor() public{
        owner = msg.sender;
    }

    struct Payment{
            uint amt;
            //The keyword 'now' can be used to get a timestamp
            uint timestamp;
    }

    struct Balance{
        uint totbal;
        uint numpay;
        // Mapping basically defines a key-value pair
        mapping(uint => Payment) payments; 
    }

    mapping(address => Balance)public Balance_record;
    event sentmoney(address indexed add1,uint amt1);
    event recmoney(address indexed add2,uint amt2);
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not the owner");
        _; //This is a placeholder which basically has all the data of the function
    }

    modifier whilenotpaused(){
        require(pause == false,"Sc is paused");
        _;
    }

    function change(bool ch)public onlyOwner{
        pause = ch;
    }

    function sendmoney()public payable whilenotpaused {
        Balance_record[msg.sender].totbal += msg.value;
        Balance_record[msg.sender].numpay += 1;
        Payment memory pay = Payment(msg.value,now);
        Balance_record[msg.sender].payments[Balance_record[msg.sender].numpay] = pay;
        emit sentmoney(msg.sender,msg.value);
    }

    function getbal()public view whilenotpaused returns(uint){
        return Balance_record[msg.sender].totbal ;
    }
    
    
    //This is a pure function
    function convert(uint amtinwei)public pure returns(uint){
        return amtinwei/1 ether;
    }

    function withdraw(uint _amt)public whilenotpaused{
        require(Balance_record[msg.sender].totbal >= _amt,"not enough funds");
        Balance_record[msg.sender].totbal -= _amt;
        msg.sender.transfer(_amt);
        /*An event is emitted, it stores the arguments passed in transaction logs. 
        These logs are stored on blockchain and are accessible using address of the contract till the contract is present on the blockchain.*/
        emit recmoney(msg.sender,_amt);
    }
    
    //You will not be able to get your money back if you send it to a destroyed account
    function destroy(address payable ender)public onlyOwner{
        selfdestruct(ender);
    }
}
