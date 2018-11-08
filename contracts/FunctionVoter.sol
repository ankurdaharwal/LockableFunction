/************************************************************************
* @title Smart Contract Function unlocking Based on Majority Votes
* @description A Smart Contract that unlocks a contract function based
*              on the majority votes for the function
* @author Ankur Daharwal - <ankur.daharwal@gmail.com>
* @license - Apache 2.0
***********************************************************************/

pragma solidity ^0.4.24;

import "./BytesLib.sol";

contract FunctionVoter {
    
    using BytesLib for bytes;
    
    /* 
    * Events
    */
    event VoteCasted ( address indexed, address, string );
    
    /* 
    * Structures
    */
    struct Vote {
        address contractAddress;
        bytes functionHash;
        bool hasVoted;
    }
    
    /* 
    *Storage Variables and Mappings
    */
    mapping ( address => Vote[] ) public votes;
    mapping ( bytes => uint256 ) totalVotes;
    
    /*
    * @dev Modifier isNewVoter - 
    *  Validates if the msg sender is a new voter
    * @param _functinName - Unique Name of the Smart Contract Address and Function Name
    */
    modifier isNewVoter(address _contractAddress, string _functionName) {
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        require(hasNotVoted(funcHash));
        _;
    }
    
    /*
    * Constructor
    */
    constructor() public { }
    
    /*
    * @dev hasNotVoted - To check if the voter has voted before
    * @param _functionHash - Bytes of Contract Address and Function Name
    * @returns - notVoted (true/false)
    */
    function hasNotVoted(
        bytes _functionHash) 
        public view returns (bool notVoted) {
            
        for ( uint i = 0 ; i < votes[msg.sender].length ; i++ ) {
            if( compareBytes(votes[msg.sender][i].functionHash, _functionHash ) ) {
                if ( votes[msg.sender][i].hasVoted ) return false;
            }
        }
        return true;
    }
    
    /*
    * @dev vote - To cast user Vote in favour of a Function
    * @param _contractAddress - Contract Address
    * @param _functionName - Name of the Function in String
    * @modifier - isNewVoter
    * @returns - Successful or not (true/false)
    */
    function vote (
        address _contractAddress, 
        string _functionName) 
        isNewVoter(_contractAddress, _functionName) 
        public returns (bool) {
    
        // check Function Name is not empty
        require(bytes(_functionName).length > 0);
        
        // check Address parameter is a Contract Address
        require(isContract(_contractAddress));
        
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        Vote memory newVote = Vote({contractAddress:_contractAddress, functionHash:funcHash, hasVoted:true});
        
        votes[msg.sender].push(newVote);
        
        totalVotes[funcHash] += 1;
        
        emit VoteCasted(msg.sender, _contractAddress, _functionName);
    }
    
    /*
    * @dev checkVotes - To check Votes and Lock/Unlock Function
    *                   based on majority votes i.e. shoudl be > 50%
    * @param _contractAddress - Contract Address
    * @param _functionName - Name of the Function in String
    * @returns - Successful or not (true/false)
    */
    function checkVotes (
        address _contractAddress, 
        string _functionName, 
        uint256 _totalVotes) 
        public returns (bool) {
    
        // check Function Name is not empty
        require(bytes(_functionName).length > 0);
        
        // check Address parameter is a Contract Address
        require(isContract(_contractAddress));
        
        // check Total Votes is not empty
        require(_totalVotes > 0);
        
        bytes memory funcHash = toBytes(_contractAddress).concat(bytes(_functionName));
        
        if( totalVotes[funcHash] > (_totalVotes/2) ){
            return _contractAddress.call(bytes4(keccak256("unlock(address,string)")), _contractAddress, _functionName);
        }
        return _contractAddress.call(bytes4(keccak256("lock(address,string)")), _contractAddress, _functionName);
    }
    
    /*
    * @dev compareString - To compare equality of two Strings
    * @param a - First String
    * @param b - Second String
    * @returns - Successful or not (true/false)
    */
    function compareBytes (
        bytes a, 
        bytes b) 
        pure internal returns (bool) {
            
        if(a.length != b.length) {
            return false;
        } 
        return keccak256(a) == keccak256(b);
    }
    
    /**
    * @dev utility function to convert Address to Bytes
    */
    function toBytes (address a) 
        pure internal returns (bytes b) {
            
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
    }
    
    /**
    * @dev utility function to check address is Contract Address
    */
    function isContract (
        address _addr) 
        public view returns (bool) {
            
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

}
