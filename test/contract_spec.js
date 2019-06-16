const BountyContract = require('Embark/contracts/BountyContract');
const EmbarkJS = require('Embark/EmbarkJS')
let accounts;

// For documentation please see https://embark.status.im/docs/contracts_testing.html
config({
  //deployment: {
  //  accounts: [
  //    // you can configure custom accounts with a custom balance
  //    // see https://embark.status.im/docs/contracts_testing.html#Configuring-accounts
  //  ]
  //},
  contracts: {
    "BountyContract": {
      args: []
    }
  }
}, (_err, web3_accounts) => {
  accounts = web3_accounts
});

contract("BountyContract Deploy", function () {
  let BountyContractInstance;
  let bountyId = '';
  let solutionHash = '';
  before(async function () {
    BountyContractInstance = await BountyContract.deploy({
      arguments: []
    }).send();
  });

  it("should register a new user", async function () {
    let result = await BountyContractInstance.methods.registerUser().send();
    //assert.strictEqual(result, true);
  });
  it("should check if user exists", async function () {
    let result = BountyContractInstance.methods.userExists().call();
    assert(result, true);
  });
  it("should add a new bounty", async function () {
    bountyId = await BountyContractInstance.methods.addBounty(web3.utils.toHex("Build Website"), web3.utils.toHex("some description"), web3.utils.toHex("some categories"), 12345, 4).send({
      value: 10
    })
    bountyId = bountyId.events.bountyIdLogger.returnValues.Id;
    assert(web3.utils.isHex(bountyId), true);
  })
  it("should check if a bounty exists", async function () {
    let result = await BountyContractInstance.methods.bountyExists(bountyId).call();
    assert(result, true);
  })
  it("should upload a solution to ipfs and return a receipt ", async function () {
    EmbarkJS.Storage.saveText("hello world").then(hash => {
      it("it should check if a bounty exists", async function () {
        let result = await BountyContractInstance.methods.proposeSolution(bountyId, hash).call();
        assert(result, true);
      })
      console.log("Hash: ", hash)
      solutionHash = hash;
    });
  })
  it("should reject a bounty solution", async function () {
    let result = await BountyContractInstance.methods.rejectSolution(bountyId).call();
    assert(result, true);
  })
  it("should accept a bounty solution", async function () {
    let result = await BountyContractInstance.methods.acceptSolution(bountyId).call();
    assert(result, true);
  })
  it("should check if a bounty has expired or not", async function () {
    let result = await BountyContractInstance.methods.bountyExpired(bountyId).call();
    assert(result, false);
  })
  it("should pause  a bounty", async function () {
    let result = await BountyContractInstance.methods.pauseBounty(bountyId).call();
    assert(result, false);
  })
  it("should check if any disputes relating to a bounty have been resolved", async function () {
    let result = await BountyContractInstance.methods.endDispute(bountyId).call();
    assert(result, false);
  })
  it("should get all bounties posted by bounty poster", async function () {
    let result = await BountyContractInstance.methods.getUserPostedBounties().call()
    assert(results != null, true)
  })
  it("should get all bounties rejected by bounty poster", async function () {
    let result = await BountyContractInstance.methods.getUserRejectedBounties().call()
    assert(results != null, true)
  })
  it("should get all bounties accepted by bounty poster", async function () {
    let result = await BountyContractInstance.methods.getUserAcceptedBounties().call()
    assert(results != null, true)
  })
})