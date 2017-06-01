pragma solidity ^0.4.6;

import './zeppelin/ownership/Ownable.sol';
import './Product.sol';

/// @title Registry - Core registry to house all products
/// @author Adam Lemmon <adamjlemmon@gmail.com>
contract Registry is Ownable {
    /// @notice Registry to hold reference to all existing products and parties
    /// Utilized to initialize manage and track all products

    /**
    * Storage
    */
    /** Reference to all existing products and parties
        mapping id to index:
            * Utilized to lookup the contract by name.
            * Maps the string of the product/party name to the index of where its
            * contract address lives within the address array

        address array:
            * Stores all contract addresses
            * Needed in order to iterate over all products or parties.  No great way
            * to iterate over a mapping

        quantity integer:
            * Required for effecient clean up and updating of arrays
            * The above array is likely to grow and shrink dynamically, semi often
            * To update array then just set the index to default value,
            * shift elements accordingly and update this param.
    **/
    mapping(bytes32=>uint) private productIdToIndex;
    address[] private products;
    uint private productQuantity;

    /**
    * Events
    */
    event LogProductAddedEvent(bytes32 productId);

    /**
    * Modifiers
    */
    /// @dev Error if product does exists
    modifier productDoesNotExist(bytes32 productId) {
        if(products[productIdToIndex[productId]] != address(0x0)) throw;
        _;
    }

    /// @dev Error if product does NOT exist
    modifier productExists(bytes32 productId) {
        if(products[productIdToIndex[productId]] == address(0x0)) throw;
        _;
    }


    /// @dev Constructor
    function Registry() { }

    /// @dev Default fallback
    function () public payable { }


    /**
    * External
    */
    /// @notice Create a new product within the registry
    /// @dev Create and add a new product to the registry
    /// Product id must be unique and not already exist
    /// Creates new product contract and stores reference to the address
    /// @param productId id of product being added
    function addProduct(bytes32 productId)
      onlyOwner
      /*productDoesNotExist(productId)*/
      external
    {
        productIdToIndex[productId] = productQuantity;

        products.push(new Product(productId));
        productQuantity++;

        LogProductAddedEvent(productId);
    }

    /// @dev Get the address of a product's contract
    function getProduct(bytes32 productId)
      onlyOwner
      external
      returns(address product)
    {
      if (productId == 0x0) throw;
      // Lookup index with id then retrieve address
      product = products[productIdToIndex[productId]];
    }

    /// @dev Permissioned getter for product quantity
    function getProductQuantity()
      onlyOwner
      external
      returns(uint)
    {
      return productQuantity;
    }
}
