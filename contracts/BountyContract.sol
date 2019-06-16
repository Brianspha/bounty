pragma solidity >= 0.5 .0;

import "../contracts/libraries/SafeMath.sol";

//@dev contract definition
contract BountyContract {
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
        bytes[] Bounties;
        bytes[] rejectedBounties;
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
        bytes32[] proposedSolutions;
        bool paused;
    }

    /*=================================== @dev modifier definitions code start===================================*/

    modifier onlyOwnwer() {
        require(msg.sender == owner, "Only owner is allowed to call this function");
        _;
    }

    /*=================================== @dev event definition code start===================================*/
    event bountyIdLogger(bytes indexed Id);
    /*=================================== @dev contract variable code start===================================*/

    address owner;
    mapping(address => User) users;
    mapping(bytes => Bounty) bounties;
    //@dev constructor
    constructor() public {
        owner = msg.sender;
    }
    /*===================================User Functions code start===================================*/
    function registerUser() public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!users[msg.sender].active, "User already registered");
        users[msg.sender].active = true;
        users[msg.sender].suspended = false;
        users[msg.sender].earnings = 0;
        return true;
    }

    function userExists() public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        return users[msg.sender].active;
    }

    /*===================================Bounty Functions code start===================================*/
    function addBounty(bytes memory title, bytes memory description, bytes memory category, uint endDate, uint difficulty) public payable {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(endDate > 0, "End date for bounty not valid");
        require(difficulty >= 1 && difficulty <= 4, "Bounty difficulty must be 1=begginer 2=intermediate 3=Hard 4=Extreme");
        require(msg.value > 0, "Insufficient funds");
        bytes memory id = abi.encode(title, endDate, difficulty, msg.sender, description, msg.value);
        require(!bounties[id].active, "Bounty already active");
        bounties[id].poster = msg.sender;
        bounties[id].title = title;
        bounties[id].description = description;
        bounties[id].startDate = now;
        bounties[id].endDate = endDate;
        bounties[id].offering = msg.value;
        bounties[id].difficulty = difficulty;
        bounties[id].active = true;
        bounties[id].submissions = 0;
        bounties[id].paused = false;
        bounties[id].category = category;
        emit bountyIdLogger(id);
    }

    function bountyExists(bytes memory bountyId) public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        return bounties[bountyId].active;
    }

    function proposeSolution(bytes memory bountyId, bytes32 solutionHash) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired");
        require(!bounties[bountyId].paused, "Bounty not accepting any solutions as there is/are a pending issues with the bounty poster");
        bounties[bountyId].proposedSolutions.push(solutionHash);
        bounties[bountyId].submissions.add(1);
        return true;
    }

    function rejectSolution(bytes memory bountyId, bytes32 solutionHash) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired");
        require(solutionHash != bytes32(""), "Invalid storage hash for proposed solution");
        require(!bounties[bountyId].paused, "Bounty cannot reject offers as there is/are a pending issues with the bounty poster");
        users[msg.sender].rejectedBounties.push(bountyId);
        return true;

    }

    function acceptSolution(bytes memory bountyId, bytes32 solutionHash) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired");
        require(solutionHash != bytes32(""), "Invalid storage hash for proposed solution");
        require(!bounties[bountyId].paused, "Bounty cannot accept offers as there is/are a pending issues with the bounty poster");

        users[msg.sender].Bounties.push(bountyId);
        users[msg.sender].earnings.add(bounties[bountyId].offering);
        bounties[bountyId].active = false;
        bounties[bountyId].endDate = now;
        return true;
    }

    function bountyExpired(bytes memory bountyId) public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster");
        return bounties[bountyId].active;
    }

    function pauseBounty(bytes memory bountyId) public onlyOwnwer returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired");
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster");
        bounties[bountyId].paused = true;
        return true;
    }

    function endDispute(bytes memory bountyId) public onlyOwnwer returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired");
        require(bounties[bountyId].paused, "Bounty dispute already resolved");
        bounties[bountyId].paused = false;
        return true;
    }

}