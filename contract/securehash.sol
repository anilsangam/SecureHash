// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SecureHash
 * @dev A smart contract for secure hash storage and verification
 * @author SecureHash Team
 */
contract Project {
    
    // Structure to store hash data
    struct HashRecord {
        bytes32 hashValue;
        address creator;
        uint256 timestamp;
        string description;
        bool isActive;
    }
    
    // Mapping from hash ID to HashRecord
    mapping(uint256 => HashRecord) public hashRecords;
    
    // Mapping from address to array of hash IDs created by that address
    mapping(address => uint256[]) public userHashes;
    
    // Counter for hash IDs
    uint256 private hashCounter;
    
    // Events
    event HashStored(uint256 indexed hashId, bytes32 indexed hashValue, address indexed creator);
    event HashVerified(uint256 indexed hashId, address indexed verifier, bool isValid);
    event HashDeactivated(uint256 indexed hashId, address indexed deactivator);
    
    // Modifiers
    modifier onlyHashCreator(uint256 _hashId) {
        require(hashRecords[_hashId].creator == msg.sender, "Only hash creator can perform this action");
        _;
    }
    
    modifier hashExists(uint256 _hashId) {
        require(hashRecords[_hashId].creator != address(0), "Hash record does not exist");
        _;
    }
    
    /**
     * @dev Store a new hash with description
     * @param _data The original data to be hashed
     * @param _description Description of the hash
     * @return hashId The ID of the stored hash
     */
    function storeHash(string memory _data, string memory _description) public returns (uint256) {
        // Generate hash from the input data
        bytes32 hashValue = keccak256(abi.encodePacked(_data));
        
        // Increment counter for new hash ID
        hashCounter++;
        uint256 newHashId = hashCounter;
        
        // Store the hash record
        hashRecords[newHashId] = HashRecord({
            hashValue: hashValue,
            creator: msg.sender,
            timestamp: block.timestamp,
            description: _description,
            isActive: true
        });
        
        // Add to user's hash list
        userHashes[msg.sender].push(newHashId);
        
        // Emit event
        emit HashStored(newHashId, hashValue, msg.sender);
        
        return newHashId;
    }
    
    /**
     * @dev Verify if provided data matches stored hash
     * @param _hashId The ID of the hash to verify against
     * @param _data The data to verify
     * @return isValid True if data matches the stored hash
     */
    function verifyHash(uint256 _hashId, string memory _data) public hashExists(_hashId) returns (bool) {
        require(hashRecords[_hashId].isActive, "Hash record is deactivated");
        
        // Generate hash from provided data
        bytes32 providedHash = keccak256(abi.encodePacked(_data));
        
        // Compare with stored hash
        bool isValid = (providedHash == hashRecords[_hashId].hashValue);
        
        // Emit verification event
        emit HashVerified(_hashId, msg.sender, isValid);
        
        return isValid;
    }
    
    /**
     * @dev Deactivate a hash record (only by creator)
     * @param _hashId The ID of the hash to deactivate
     */
    function deactivateHash(uint256 _hashId) public hashExists(_hashId) onlyHashCreator(_hashId) {
        require(hashRecords[_hashId].isActive, "Hash is already deactivated");
        
        // Deactivate the hash
        hashRecords[_hashId].isActive = false;
        
        // Emit deactivation event
        emit HashDeactivated(_hashId, msg.sender);
    }
    
    /**
     * @dev Get hash record details
     * @param _hashId The ID of the hash
     * @return creator The address that created the hash
     * @return timestamp When the hash was created
     * @return description Description of the hash
     * @return isActive Whether the hash is active
     */
    function getHashDetails(uint256 _hashId) public view hashExists(_hashId) returns (
        address creator,
        uint256 timestamp,
        string memory description,
        bool isActive
    ) {
        HashRecord memory record = hashRecords[_hashId];
        return (record.creator, record.timestamp, record.description, record.isActive);
    }
    
    /**
     * @dev Get all hash IDs created by a user
     * @param _user The address of the user
     * @return Array of hash IDs created by the user
     */
    function getUserHashes(address _user) public view returns (uint256[] memory) {
        return userHashes[_user];
    }
    
    /**
     * @dev Get total number of hashes stored
     * @return Total count of hash records
     */
    function getTotalHashes() public view returns (uint256) {
        return hashCounter;
    }
}
