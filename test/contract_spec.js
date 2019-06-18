const BountyContract = require('Embark/contracts/Bounty');
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
    "Bounty": {}
  }
}, (_err, web3_accounts) => {
  accounts = web3_accounts
});

contract("BountyContract Deploy", async () => {
  let bountyId = '';
  let solutionHash = '';
  it("should register a new user", async () => {
    let result = await BountyContract.methods.registerUser().send({from:accounts[1]});
    console.log(result.from)
  });
  it("should check if user exists", async () => {
    let result = await BountyContract.methods.userExists().call();
    assert.strictEqual(result, true);
  });

  it("should add a new bounty", async () => {
    bountyId = await BountyContract.methods.addBounty(web3.utils.fromAscii("Build Website"), web3.utils.fromAscii("some description"), web3.utils.fromAscii("some categories"), 12345, 4).send({
      value: 10,
    })
    bountyId = bountyId.events.bountyIdLogger.returnValues.Id;
    assert.strictEqual(web3.utils.isHex(bountyId), true);
  })

  it("should check if a bounty exists", async () => {
    let result = await BountyContract.methods.bountyExists(bountyId).call();
    assert.strictEqual(result, true);
  })

  it("should reject a bounty solution", async () => {
    let result = await BountyContract.methods.rejectSolution(bountyId).send();
  })

  it("should check if a bounty has expired or not", async () => {
    let result = await BountyContract.methods.bountyExpired(bountyId).call();
    assert.strictEqual(result, false);
  })
  it("should pause a bounty", async () => {
    let result = await BountyContract.methods.pauseBounty(bountyId).send();
  })

  it("should end any disputes relating to a bounty ", async () => {
    let result = await BountyContract.methods.endDispute(bountyId).send();
  })

  it("should accept a bounty solution", async () => {
    let result = await BountyContract.methods.acceptSolution(bountyId).send();
  })

  it("should get all bounties posted by bounty poster", async () => {
    let result = await BountyContract.methods.getUserPostedBounties().call()
    assert.strictEqual(result.length > 0, true)
  })

  it("should get all bounties rejected by bounty poster", async () => {
    let result = await BountyContract.methods.getUserRejectedBounties().call()
    assert.strictEqual(result.length > 0, true)
  })

  it("should get all bounties accepted by bounty poster", async () => {
    let result = await BountyContract.methods.getUserAcceptedBounties().call()
    assert.strictEqual(result.length > 0, true)
  })

  it("should upload a solution to ipfs and return a receipt ", async () => {
    EmbarkJS.Storage.saveText("hello world its me").then(hash => {
      console.log("Hash: ", hash)
      solutionHash = hash;
      assert.strictEqual(hash != null, true);
    }).catch((err => {
      console.log(err)
    }))
  })

  it("should get a solution uploaded by a bounty hunter from ipfs", async () => {
    EmbarkJS.Storage.get(solutionHash).then(content => {
      assert.strictEqual(content != null, true)
      console.log("content: ", content)

    }).catch((err => {
      console.log(err)
    }))
  })

})