//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD=50 * 1e18;

    address[] public funders;
    mapping(address=>uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner=msg.sender;
    }

    function fund() public payable{
        
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didnt send enough!");

        //TASK-1-------------------------------------------------------------->
        bool duplicateAddress=false;
        for(uint256 funderIndex=0; funderIndex<funders.length; funderIndex++){
            if(funders[funderIndex]==msg.sender){
                duplicateAddress=true;
            }
        }
        if(duplicateAddress==false){
            funders.push(msg.sender);
        }
        //--------------------------------------------------------------------->
        
        addressToAmountFunded[msg.sender]+=msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 funderIndex=0; funderIndex<funders.length; funderIndex++){
            address funder=funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        //reset the array
        funders=new address[](0);

        (bool callSuccess, )=payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    modifier onlyOwner{
        // require(msg.sender==i_owner, "sender is not the owner");
        if(msg.sender!=i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }
    
}
