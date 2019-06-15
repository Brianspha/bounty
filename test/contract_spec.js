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

contract("BountyContract", function () {
this.timeout(0);

it("should register a new user", async function () {
  let result = await BountyContract.methods.registerUser().call();
  assert.strictEqual(result, true);
});
it("should check if user exists", async function () {
  let result = BountyContract.methods.userExists().call();
  assert(result, true);
});
it("should add a new bounty", async function () {
  let bountyId = await BountyContract.methods.addBounty(web3.utils.toHex("Build Website"), web3.utils.toHex("some description"), web3.utils.toHex("some categories"), 12345, 4).call({
    value: 10
  })
})
  it("should check if a bounty exists", async function () {
    let result = await BountyContract.methods.bountyExists(bountyId).call();
    assert(result, true);
  })
  it("should add upload a solution to ipfs and return a receipt ", async function () {
    EmbarkJS.Storage.saveText("hello world").then(solutionHash => {
      it("it should check if a bounty exists", async function () {
        let result = await BountyContract.methods.proposeSolution(bountyId, solutionHash).call();
        assert(result, true);
      })
      console.log("Hash: ", solutionHash)
    });
  })
  it("should reject a bounty solution", async function () {
    let result = await BountyContract.methods.rejectSolution(bountyId, solutionHash).call();
    assert(result, true);
  })
  it("should accept a bounty solution", async function () {
    let result = await BountyContract.methods.acceptSolution(bountyId, solutionHash).call();
    assert(result, true);
  })
  it("should check if a bounty has expired or not", async function () {
    let result = await BountyContract.methods.bountyExpired(bountyId).call();
    assert(result, false);
  })
  it("should pause  a bounty", async function () {
    let result = await BountyContract.methods.pauseBounty(bountyId).call();
    assert(result, false);
  })
  it("should check if any disputes relating to a bounty have been resolved", async function () {
    let result = await BountyContract.methods.endDispute(bountyId).call();
    assert(result, false);
  })
})
