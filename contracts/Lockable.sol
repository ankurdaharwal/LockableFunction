/***********************************************************************
 * @title Lockable Smart Contract
 * @description A Smart Contract that allows functions to be Lockable
 * @author Ankur Daharwal - <ankur.daharwal@gmail.com>
 * @license - Apache 2.0
 **********************************************************************/

pragma solidity ^0.4.24;

import "./FunctionVoter.sol";
import "./BytesLib.sol";

/**
 * @title Lockable
 * @dev Parent contract which allows children contracts to implement 
 *      a locking mechanism to it's functions.
 */
 

contract Lockable {
    
    using BytesLib for bytes;

    /*
    * Events - Locked and Unlocked
    */
    event Locked (bytes functionHash) ;
    event Unlocked (bytes functionHash) ;
    
    /*
    * Storage Variables
    */
    FunctionVoter funcVoter;
    uint256 private totalVotes;
    mapping ( bytes => bool ) private locked;
    
    /*
    * Modifiers
    */
    
    /**
    * @dev Modifier to make a function callable only 
    * when called by Function Voter Contract
    */
    modifier onlyLocker() {
        require(msg.sender == address(funcVoter));
    _;
    }
    
    /**
    * @dev Modifier to make a function callable only 
    * when the contract is not locked
    */
    modifier notLocked(bytes _functionHash) {
        require(!locked[_functionHash]);
    _;
    }
    
    /**
    * @dev Modifier to make a function callable only 
    * when the contract is locked.
    */
    modifier isLocked(bytes _functionHash) {
        require(locked[_functionHash]);
    _;
    }
    
    /*
    * constructor
    * @param _funcVoter - Address of the Function Voter Contract
    */
    constructor(address _funcVoter) internal {
        funcVoter = FunctionVoter(_funcVoter);
    }
    
    /**
    * @return true if the contract function is locked, false otherwise.
    */
    function isFunctionLocked (
        address _contractAddress, 
        string _functionName, 
        uint256 _totalVotes ) 
        public returns(bool) {
        
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        funcVoter.checkVotes(_contractAddress, _functionName, _totalVotes);
        return locked[funcHash];
    }
    
    /**
    * @dev called by the owner to lock, triggers stopped state
    */
    function lock(
        address _contractAddress, 
        string _functionName) 
        public onlyLocker 
        notLocked(toBytes(_contractAddress).concat(bytes(_functionName))) {
        
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        locked[funcHash] = false;
        emit Locked(funcHash);
    }
    
    /**
    * @dev called by the owner to unlock, returns to normal state
    */
    function unlock(
        address _contractAddress, 
        string _functionName) 
        public onlyLocker 
        isLocked(toBytes(_contractAddress).concat(bytes(_functionName))) {
            
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        locked[funcHash] = true;
        emit Unlocked(funcHash);
    }
    
    /**
    * @dev utility function to convert Address to Bytes
    */
    function toBytes(address a) 
        pure internal returns (bytes b) {
            
        assembly {
        let m := mload(0x40)
        mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
        mstore(0x40, add(m, 52))
        b := m
        }
    }

}
