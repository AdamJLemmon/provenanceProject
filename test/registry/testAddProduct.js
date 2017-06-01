const Registry = artifacts.require("./Registry.sol");
const newProduct = 'newProduct';
let registry;

contract('Registry', accounts => {
  const owner = accounts[0];

  it('addProduct should create tx and add product address',
    function() {
      return Registry.new({from: owner}).then(registry => {
        return registry.addProduct(newProduct, {from: owner});

    }).then(result => {
      assert.isNotNull(
        result.tx,
        'addProduct was supposed to return a tx id but it is null'
      );

      assert.isNumber(
        result.receipt.blockNumber,
        'addProduct was supposed to return a blockNumber'
      );

      assert.isNumber(
        result.receipt.gasUsed,
        'addProduct was supposed to return use gas for tx'
      );
    });
  });

  it('addProduct not as owner should throw invalid JUMP',
    function() {
      return Registry.new({from: owner}).then(registry => {
        return registry.addProduct(newProduct, {from: accounts[1]});

    }).then(returnValue => {
      assert(false, 'addProduct was supposed to throw but did not when adding duplicate');

    }).catch(function(error){
      if(error.toString().indexOf('invalid JUMP') == -1) {
        assert(false, error.toString());
      }
    });
  });

  // it('addProduct when adding a product that exists should throw invalid JUMP',
  //   function() {
  //     return Registry.new().then(_registry => {
  //       registry = _registry;
  //       return registry.addProduct(newProduct, {from: owner});
  //
  //     }).then(returnValue => {
  //       return registry.addProduct(newProduct, {from: owner});
  //
  //     }).then(returnValue => {
  //       assert(false, 'addProduct was supposed to throw but did not when adding duplicate');
  //
  //     }).catch(function(error){
  //       if(error.toString().indexOf('invalid JUMP') == -1) {
  //       assert(false, error.toString());
  //     }
  //   });
  // });
});
