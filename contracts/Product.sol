pragma solidity ^0.4.6;

import './zeppelin/ownership/Ownable.sol';

/// @title Product
/// @author Adam Lemmon <adamjlemmon@gmail.com>
contract Product is Ownable {
    /// @dev Represents a unique product as contained within the registry
    /// Contains:
    /// - a history of all acquired data of its type
    /// - associations to parties
    /// - specific rules or constraints it must abide by

    /**
    * Constants
    */
    // Restrictions for each product
    // The quantity limit that may not be exceeded within a time interval
    uint private constant quantityLimit = 3;
    uint private constant quantityLimitTimeInterval = 5000000; // 5s in micro seconds;

    /**
    * Storage
    */
    bytes32 public id;

    // TODO: how to lookup data?? Store some mapping to define index, store structs with
    // 'queryable' attributes
    // TODO Consider just storing merkle root perhaps?? Define storage limits.
    // array of encrypted data hashes
    // 1 to 1 mapping of data hashes to timestamps
    string[] private dataHistory;
    // Utilized for quick lookup to confirm limits not exceeded
    uint[] private dataTimestamps; // microseconds

    // array of associated parties, these will be notified when events occur
    // Eg. if quantity limit is exceeded an email will be sent to these parties
    bytes32[10] private parties;
    uint8 partyCount;

    /**
    * Events
    */
    event LogDataAdded(string dataHash, uint timestamp);
    event LogQuantityLimitExceeded(bytes32 _event, bytes32[10] parties);

    /// @dev Constructor
    function Product(bytes32 _id){
        id = _id;
    }

    /**
    * External
    */
    /// @dev Add a new data hash into data history
    /// Accompanied by a timestamp in order to confirm limits within time intervals
    /// @param dataHash hash of the data to be utilized by server for lookup of raw data
    /// @param latest represents the timestamp as an interger in microseconds
    // TODO permissioning, consider defining an account specific to this product??
    function addData(string dataHash, uint latest) external {
        dataHistory.push(dataHash);
        dataTimestamps.push(latest);
        LogDataAdded(dataHash, latest);

        // if the length is greater than the quantity limit check if it has been exceeded
        // Check required or will try to access array at invalid index
        if (dataHistory.length > quantityLimit) {
            uint minimumIndex = dataHistory.length - 1 - quantityLimit;

            // If the difference is less than the limit it has been exceeded
            // Too many products have been added in the time interval
            if ((latest - dataTimestamps[minimumIndex]) < quantityLimitTimeInterval) {
              LogQuantityLimitExceeded('Quantity limit exceeded!', parties);
            }
        }
    }

    /// @dev Placeholder to add an association with a party for this product
    /// @param partyId the party to add to this product
    /// TODO define association types, etc, filter the notifications
    function addPartyAssociation(bytes32 partyId) external {
        if (partyCount == parties.length - 1) throw;
        parties[partyCount] = partyId;
        partyCount++;
    }

    /// @dev Retrieve data from this product
    /// @return latestData latest hash of data pushed
    /// TODO: consider advanced queries for lookup
    /// Currently returns the latest dataHash
    // TODO: define this!! Permission it.
    function getData()
      external
      constant
      onlyOwner
      returns(string latestData)
    {
        if(dataHistory.length > 0) {
            latestData = dataHistory[dataHistory.length - 1];
        }
        else {
            latestData = 'Error: No data exists!';
        }
    }
}
