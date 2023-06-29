// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract PurchaseAgreement{
    uint public value;
    address payable public buyer;
    address payable  public seller;

    enum State{Created, Locked, Released, Inactive}
    State public state;

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
    }

    error InvalidState();
    //only buyer can call this function
    error OnlyBuyer();
     //only seller can call this function
    error OnlySeller();

    modifier inState(State state_){
        if(state != state_){
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

     modifier onlySeller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }

    function confirmPayment() external inState(State.Created) payable{
        require(msg.value == (2 * value), "Please send amount 2* the purchase amount");
        buyer = payable (msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Released;
        buyer.transfer(value);
    }

    function paySeller() external onlySeller inState(State.Released){
        state = State.Inactive;

        seller.transfer(3 * value);
    }

    function abort() external onlySeller inState(State.Inactive){
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

}