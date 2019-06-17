pragma solidity ^0.5.9;
import "../contracts/libraries/SafeMath.sol";

//@dev contract definition
contract BountyContract {
event __StatementCoverage(uint32 value);
    using SafeMath
    for uint256;
    /*=================================== @dev structs definition code start===================================*/
    /**
    @dev User struct represents a user who eitheir posts bounties or a bounty seeker
     @atr id represents the address of the User
     @atr earnings represents the total earnings by User
     @atr Bounties represents the ids of all the bounties the user has completed
     @active indicates if the user is active or not
     @atr suspended indicates if the user is suspended or not
     */
    struct User {
        address id;
        uint256 earnings;
        bytes32[] acceptedBounties;
        bytes32[] rejectedBounties;
        bytes32[] postedBounties;
        bool active;
        bool suspended;
    }

    /**
    @dev bounty struct representing a typical bounty that is submitted on the platform
    @atr id unique identifier for the Bounty 
    @atr title represents the title of the bounty 
    @atr description represents the bountys description usually what the bounty wants done 
    @atr start indicates the date the bounty was posted
    @atr end indicates the date the bounty expires
    @atr offering indicates the amount in ether the bounty poster is willing to pay
    @atr difficulty indicates the difficulty level of the bounty 1-begginer 2-intermediate 3-Hard 4-Extreme
    @atr submissions the number of submissions the bounty has recieved
    @atr indicates if the bounty has expired or not
    @atr poster the poster of the bounty
    @atr paused in the instance where theres a dispute this atribute will be activated
    @atr category represents the category/categories the bounty falls under
    @notice poster atr cannot be used as an id as user may have multiple bounties posted looping may be costly
     */
    struct Bounty {
        bytes id;
        bytes title;
        bytes description;
        uint startDate;
        uint endDate;
        uint256 offering;
        bytes category;
        uint difficulty;
        uint256 submissions;
        bool active;
        address poster;
        bytes[] proposedSolutions;
        bool paused;
    }

    /*=================================== @dev modifier definitions code start===================================*/

    modifier onlyOwnwer() {
emit __StatementCoverage(1000001);
        require(msg.sender == owner, "Only owner is allowed to call this function");
emit __StatementCoverage(1000002);
        _;
    }

    /*=================================== @dev event definition code start===================================*/
    event bountyIdLogger(bytes32 Id);
    /*=================================== @dev contract variable code start===================================*/

    address owner;
    mapping(address => User) users;
    mapping(bytes32 => Bounty) bounties;
    //@dev constructor
    constructor() public {
emit __StatementCoverage(1000003);
        owner = msg.sender;
    }
    /*===================================User Functions code start===================================*/
    function registerUser() public returns(bool) {
emit __StatementCoverage(1000004);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000005);
        require(!users[msg.sender].active, "User already registered");
emit __StatementCoverage(1000006);
        users[msg.sender].active = true;
emit __StatementCoverage(1000007);
        users[msg.sender].suspended = false;
emit __StatementCoverage(1000008);
        users[msg.sender].earnings = 0;
emit __StatementCoverage(1000009);
        return true;
    }

    function userExists() public  returns(bool) {
emit __StatementCoverage(1000010);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000011);
        return users[msg.sender].active;
    }

    /*===================================Bounty Functions code start===================================*/
    function addBounty(bytes memory title, bytes memory description, bytes memory category, uint endDate, uint difficulty) public payable {
emit __StatementCoverage(1000012);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000013);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000014);
        require(endDate > 0, "End date for bounty not valid");
emit __StatementCoverage(1000015);
        require(difficulty >= 1 && difficulty <= 4, "Bounty difficulty must be 1=begginer 2=intermediate 3=Hard 4=Extreme");
emit __StatementCoverage(1000016);
        require(msg.value > 0, "Insufficient funds");
emit __StatementCoverage(1000017);
        bytes32 id = keccak256((abi.encode(title, endDate, difficulty, msg.sender, description, msg.value)));
emit __StatementCoverage(1000018);
        require(!bounties[id].active, "Bounty already active");
emit __StatementCoverage(1000019);
        bounties[id].poster = msg.sender;
emit __StatementCoverage(1000020);
        bounties[id].title = title;
emit __StatementCoverage(1000021);
        bounties[id].description = description;
emit __StatementCoverage(1000022);
        bounties[id].startDate = block.timestamp;
emit __StatementCoverage(1000023);
        bounties[id].endDate = endDate;
emit __StatementCoverage(1000024);
        bounties[id].offering = msg.value;
emit __StatementCoverage(1000025);
        bounties[id].difficulty = difficulty;
emit __StatementCoverage(1000026);
        bounties[id].active = true;
emit __StatementCoverage(1000027);
        bounties[id].submissions = 0;
emit __StatementCoverage(1000028);
        bounties[id].paused = false;
emit __StatementCoverage(1000029);
        bounties[id].category = category;
emit __StatementCoverage(1000030);
        users[msg.sender].postedBounties.push(id);
emit __StatementCoverage(1000031);
        emit bountyIdLogger(id);
    }

    function bountyExists(bytes32 bountyId) public  returns(bool) {
emit __StatementCoverage(1000032);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000033);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000034);
        return bounties[bountyId].active;
    }

    function proposeSolution(bytes32 bountyId, bytes memory solutionHash) public returns(bool) {
emit __StatementCoverage(1000035);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000036);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000037);
        require(bounties[bountyId].active, "Bounty already expired");
emit __StatementCoverage(1000038);
        require(bounties[bountyId].poster != msg.sender, "Cannot propose solution as you are the owner of the Bounty");
emit __StatementCoverage(1000039);
        require(!bounties[bountyId].paused, "Bounty not accepting any solutions as there is/are a pending issues with the bounty poster");
emit __StatementCoverage(1000040);
        bounties[bountyId].proposedSolutions.push(solutionHash);
emit __StatementCoverage(1000041);
        bounties[bountyId].submissions.add(1);
emit __StatementCoverage(1000042);
        return true;
    }

    function rejectSolution(bytes32 bountyId) public returns(bool) {
emit __StatementCoverage(1000043);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000044);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000045);
        require(bounties[bountyId].active, "Bounty already expired");
emit __StatementCoverage(1000046);
        require(!bounties[bountyId].paused, "Bounty cannot reject offers as there is/are a pending issues with the bounty poster");
emit __StatementCoverage(1000047);
        users[msg.sender].rejectedBounties.push(bountyId);
emit __StatementCoverage(1000048);
        return true;
    }

    function acceptSolution(bytes32 bountyId) public returns(bool) {
emit __StatementCoverage(1000049);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000050);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000051);
        require(bounties[bountyId].poster == msg.sender, "Only owner of the Bounty is allowed to accept solutions");
emit __StatementCoverage(1000052);
        require(bounties[bountyId].active, "Bounty already expired");
emit __StatementCoverage(1000053);
        require(!bounties[bountyId].paused, "Bounty cannot accept offers as there is/are a pending issues with the bounty poster");

emit __StatementCoverage(1000054);
        users[msg.sender].acceptedBounties.push(bountyId);
emit __StatementCoverage(1000055);
        users[msg.sender].earnings.add(bounties[bountyId].offering);
emit __StatementCoverage(1000056);
        bounties[bountyId].active = false;
emit __StatementCoverage(1000057);
        bounties[bountyId].endDate = block.timestamp;
emit __StatementCoverage(1000058);
        return true;
    }

    function bountyExpired(bytes32 bountyId) public  returns(bool) {
emit __StatementCoverage(1000059);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000060);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000061);
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster");
emit __StatementCoverage(1000062);
        return !bounties[bountyId].active;
    }

    function pauseBounty(bytes32 bountyId) public onlyOwnwer returns(bool) {
emit __StatementCoverage(1000063);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000064);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000065);
        require(bounties[bountyId].active, "Bounty already paused");
emit __StatementCoverage(1000066);
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster");
emit __StatementCoverage(1000067);
        bounties[bountyId].paused = true;
emit __StatementCoverage(1000068);
        return true;
    }

    function endDispute(bytes32 bountyId) public onlyOwnwer returns(bool) {
emit __StatementCoverage(1000069);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000070);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000071);
        require(bounties[bountyId].active, "Bounty not in dispute");
emit __StatementCoverage(1000072);
        require(!bounties[bountyId].paused, "Bounty dispute already resolved");
emit __StatementCoverage(1000073);
        bounties[bountyId].paused = false;
emit __StatementCoverage(1000074);
        return true;
    }

    function getUserPostedBounties() public  returns(bytes32[] memory) {
emit __StatementCoverage(1000075);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000076);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000077);
        return users[msg.sender].postedBounties;
    }

    function getUserRejectedBounties() public  returns(bytes32[] memory) {
emit __StatementCoverage(1000078);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000079);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000080);
        return users[msg.sender].rejectedBounties;
    }

    function getUserAcceptedBounties() public  returns(bytes32[] memory) {
emit __StatementCoverage(1000081);
        require(msg.sender != address(0), "Invalid sender address");
emit __StatementCoverage(1000082);
        require(users[msg.sender].active, "User not registered");
emit __StatementCoverage(1000083);
        return users[msg.sender].acceptedBounties;
    }
}