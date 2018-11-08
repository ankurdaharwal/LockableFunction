/******************************************************************************
* @title Lockable Smart Contract Example Implementation
* @description An example Smart Contract that unlocks a contract function based
*              on the majority votes for the function
* @author Ankur Daharwal - <ankur.daharwal@gmail.com>
* @license - Apache 2.0
******************************************************************************/

pragma solidity ^0.4.24;

import "./Lockable.sol";

    /**
    * @title Lockable Smart Contract Example
    * @dev The LockableContractExample implements Lockable
    **/
    
contract LockableContractExample is Lockable {
    
    /**
     * Events
     */
    event Add (uint256 a, uint256 b);

    /**
     * Storage Variables
     */
    uint256 private totalVotes;
    
    /**
     * Modifiers
     */
    
    /**
    * @dev Modifier to check the Function Lock based on Votes
    * when called by Function Voter Contract
    */
    modifier checkLock (string _functionName) {
        require(!isFunctionLocked(msg.sender, _functionName, totalVotes));
    _;
    }
    
    /**
     * constructor
     * @param _totalVotes - Total Votes required at least 2 votes
     * majority of 50%+ votes are required to unlock function
     */
    constructor(uint256 _totalVotes) public {
        require(_totalVotes > 2);
        totalVotes = _totalVotes;
    }
    
    /**
     * Example Function to Test Function Voting Lock/UnLock functionality
     */
    function add(
        uint256 a, 
        uint256 b) 
        public checkLock("add") returns (uint256) {

        emit Add(a, b);  
        return a + b ;
        
    }

}
