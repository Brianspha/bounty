pragma solidity >= 0.5 .0;
import "../contracts/interfaces/IERC720.sol";
import "../contracts/interfaces/IBountyContract.sol";
import "../contracts/math/SafeMath.sol";
//@dev contract definition
contract BountyContract is IBountyContract {
    using SafeMath
    for uint256;

    /*=================================== @dev modifier definitions code start===================================*/

    modifier onlyOwnwer() {
        require(msg.sender == owner, "Only owner is allowed to call this function");
        _;
    }

    /*=================================== @dev contract variable code start===================================*/
    address owner;
    mapping(address => User) users;
    mapping(bytes32 => Bounty) bounties;

    //@dev constructor
    constructor() public {
        require(msg.sender != address(0), "Invalid sender address");
        owner = msg.sender;
        registerUser();
    }
    /*===================================User Functions code start===================================*/
    /**
     *@dev registerUser registers a new users
     */
    function registerUser() public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!users[msg.sender].active, "User already registered");
        users[msg.sender].active = true;
        users[msg.sender].suspended = false;
        users[msg.sender].earnings = 0;
        users[msg.sender].ranking = 0;
        return true;
    }
    /**
    *@dev updateUserRanking updates a users ranking
    @notice not yet implemented in front end
    */
    function updateUserRanking(uint256 rank, address user) public onlyOwnwer returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(user != address(0), "Invalid user address");
        require(!users[user].punished, "User is currently punished and cannot use the platform until further notice");
        require(!users[user].active, "User already registered");
        require(rank > 0, "Invalid ranking paramter rank must be greater than 0");
        users[user].ranking = rank;
        return true;
    }
    /**
     *@dev userExists checks if a user exits
     */
    function userExists() public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        return users[msg.sender].active;
    }
    /**
    *@dev suspendUser responsible for suspending a user
    @notice introduces front running vulnerability
    @param user the user to be punished
    */
    function suspendUser(address user) public onlyOwnwer returns(bool) {
        require(msg.sender != address(0), "Invalid owner address");
        require(user != address(0), "Invalid user address");
        require(users[user].active, "User not registered");
        require(!users[user].punished, "user already serving punishment");
        users[user].punished = false;
        return users[user].punished;
    }
    /*===================================Bounty Functions code start===================================*/
    /**
    *@dev addBounty responsible for adding a new bounty to the platform
    @param title title of the bounty
    @param description description of what the bounty poster wants achieved
    @param category the categories the bounty falls under
    @param endDate the last day the bounty be closed
    @param difficulty represents the difficulty assocciated with trying to solve the bounty
    */
    function addBounty(bytes memory title, bytes memory description, bytes memory category, uint endDate, uint difficulty)
    public payable {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        require(endDate > 0, "End date for bounty not valid");
        require(difficulty >= 1 && difficulty <= 4, "Bounty difficulty must be 1=begginer 2=intermediate 3=Hard 4=Extreme");
        require(msg.value > 0, "Invalid ether amount please ensure ether sent is greater than 0");
        bytes32 id = keccak256((abi.encode(title, endDate, difficulty, msg.sender, description, msg.value)));
        require(!bounties[id].active, "Bounty already active");
        bounties[id].poster = msg.sender;
        bounties[id].title = title;
        bounties[id].description = description;
        bounties[id].startDate = block.timestamp;
        bounties[id].endDate = endDate;
        bounties[id].offering = msg.value;
        bounties[id].difficulty = difficulty;
        bounties[id].active = true;
        bounties[id].submissions = 0;
        bounties[id].paused = false;
        bounties[id].category = category;
        users[msg.sender].postedBounties.push(id);
        emit bountyIdLogger(id);
    }
    /**
    *@dev addBountyOfferToken responsible for adding a new bounty to the platform but using an ERC720 token
    @param title title of the bounty
    @param description description of what the bounty poster wants achieved
    @param category the categories the bounty falls under
    @param endDate the last day the bounty be closed
    @param difficulty represents the difficulty assocciated with trying to solve the bounty
    */
    function addBountyOfferToken(bytes memory title, bytes memory description, bytes memory category, uint endDate, uint difficulty, address tokenAddress, uint256 amount) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(tokenAddress != address(0), "Invalid Token address");
        require(amount > 0, "Token pledged amount must be greater than 0");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        require(endDate > 0, "End date for bounty not valid");
        require(difficulty >= 1 && difficulty <= 4, "Bounty difficulty must be 1=begginer 2=intermediate 3=Hard 4=Extreme");
        bytes32 id = keccak256((abi.encode(title, endDate, difficulty, msg.sender, description, 0)));
        require(!bounties[id].active, "Bounty already active");
        IERC20 token = IERC20(tokenAddress);
        bool results = token.approve(owner, amount);
        require(results, "Insufficient funds please ensure you have sufficient tokens in your account");
        bounties[id].poster = msg.sender;
        bounties[id].title = title;
        bounties[id].description = description;
        bounties[id].startDate = block.timestamp;
        bounties[id].endDate = endDate;
        bounties[id].isToken = true;
        bounties[id].difficulty = difficulty;
        bounties[id].active = true;
        bounties[id].submissions = 0;
        bounties[id].paused = false;
        bounties[id].category = category;
        users[msg.sender].postedBounties.push(id);
        bounties[id].tokenPayment.tokenAddress = tokenAddress;
        bounties[id].tokenPayment.amount = amount;
        bounties[id].tokenPayment.active = true;
        emit bountyIdLogger(id);
    }
    /**
    *@dev bountyExists responsible for checking if a bounty exits 
    @param bountyId the unique identifier of the bounty
     */
    function bountyExists(bytes32 bountyId) public view returns(bool) {
        require(msg.sender !=
            address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        return
        bounties[bountyId].active;
    }
    /** *@dev proposeSolution responsible for proposing a solution to a given bounty
        @param bountyId the unique identifier of the bounty
        @param solutionHash the hash of the solution stored on IPFS
           */
    function proposeSolution(bytes32 bountyId, string memory solutionHash) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        require(bounties[bountyId].active, "Bounty already expired");
        require(bounties[bountyId].poster !=
            msg.sender, "Cannot propose solution as you are the owner of the Bounty");
        require(!bounties[bountyId].paused, "Bounty not accepting any solutions as there is/are a pending issues with the bounty poster ");
        require(!bounties[bountyId].bountyHunters[msg.sender].active, "Only one solution per bounty is allowed per bounty hunter");
        bounties[bountyId].proposedSolutions[solutionHash] = Solution(solutionHash, msg.sender, bounties[bountyId].submissions);
        bounties[bountyId].proposedSolutionsKeys.push(solutionHash);
        bounties[bountyId].submissions.add(1);
        bounties[bountyId].bountyHuntersKeys.push(msg.sender);
        bounties[bountyId].bountyHunters[msg.sender] = Hunter(msg.sender, true);
        return true;
    }
    /** 
       *@dev rejectSolution responsible for rejecting a solution to a given bounty
        @param bountyId the unique identifier of the bounty 
        @param solutionHash the hash of the solution stored on IPFS
        @param bountyHunter the address of the hunter whos solution to reject
        */
    function rejectSolution(bytes32 bountyId, string memory solutionHash, address bountyHunter) public returns(bool) {
        require(msg.sender !=
            address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already expired or is not registered");
        require(!bounties[bountyId].paused, "Bounty cannot reject offers as there is/are a pending issues with the bounty poster ");
        require(bountyHunter != address(0), "Invalid Bounty hunter address");
        users[msg.sender].rejectedBounties.push(bountyId);
        delete bounties[bountyId].proposedSolutions[solutionHash];
        delete bounties[bountyId].bountyHunters[bountyHunter];
        return true;
    }
    /** 
     *@dev acceptSolution responsible for accepting a solution to a given bounty and rewards the bounty hunter with the offering pledged by the bounty
     *@param bountyId the unique identifier of the bounty 
     *@param bountyHunterAddress the address of the bountyHunter
     */
    function acceptSolution(bytes32 bountyId, address bountyHunterAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(bountyHunterAddress !=
            address(0), "Invalid Bounty Hunter Address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        require(bounties[bountyId].poster == msg.sender, "Only owner of the Bounty is allowed to accept solutions");
        require(bounties[bountyId].active, "Bounty already expired");
        require(!bounties[bountyId].paused, "Bounty cannot accept offers as there is/are a pending issues with the bounty poster ");
        if (bounties[bountyId].isToken) {
            IERC20 token = IERC20(bounties[bountyId].tokenPayment.tokenAddress);
            bool
            results = token.transferFrom(owner,bountyHunterAddress, bounties[bountyId].tokenPayment.amount);
            require(results, "Insufficient funds please ensure you have sufficient funds in your account");
        } else {
            users[msg.sender].acceptedBounties.push(bountyId);
            users[msg.sender].earnings.add(bounties[bountyId].offering);
        }
        bounties[bountyId].active = false;
        bounties[bountyId].endDate = block.timestamp;
        bounties[bountyId].winner = bountyHunterAddress;
        return true;
    }
    /** *@dev bountyExpired responsible for checking if a given bounty has expired or not
         @param bountyId the unique identifier of the bounty 
    */
    function bountyExpired(bytes32 bountyId) public view returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster ");
        return !bounties[bountyId].active;
    }
    /** *@dev pauseBounty responsible for pausing a bounty in the instance of a dispute arising
         @param bountyId the unique identifier of the bounty 
    */
    function pauseBounty(bytes32 bountyId) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].active, "Bounty already paused");
        require(!bounties[bountyId].paused, "Bounty cannot be turned off as there is/are a pending issues with the bounty poster ");
        bounties[bountyId].paused = true;
        return true;
    }
    /** *@dev endDispute responsible for ending a dispute after an agreement ahas been reach by both the bounty hunter and bounty poster
         @param bountyId the unique identifier of  the bounty
     */
    function endDispute(bytes32 bountyId) public returns(bool) {
        require(msg.sender !=
            address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(bounties[bountyId].poster == msg.sender, "Only an owner of the bounty is allowed to end a dispute");
        require(bounties[bountyId].active, "Bounty not in dispute");
        require(bounties[bountyId].paused, "Bounty dispute already resolved");
        bounties[bountyId].paused = false;
        return
        true;
    }
    /**
     *@dev getUserPostedBounties responsible for getting all posted bounties by a given user 
     */
    function getUserPostedBounties() public view returns(bytes32[] memory) {
        require(msg.sender !=
            address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        return users[msg.sender].postedBounties;
    }
    /**
     *@dev getUserRejectedBounties responsible for getting all rejected bounties by a given user 
     */
    function getUserRejectedBounties() public view returns(bytes32[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        return users[msg.sender].rejectedBounties;
    }
    /** *@dev getUserAcceptedBounties responsible for getting all accepted bounties by a given user 
     */
    function getUserAcceptedBounties() public view returns(bytes32[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(users[msg.sender].active, "User not registered");
        require(!users[msg.sender].punished, "User is currently punished and cannot use the platform until further notice");
        return users[msg.sender].acceptedBounties;
    }
    /** *@dev getaddresseofBountyHunters responsible for getting all addresses of all bounty hunters who have submitted solutions to a given bounty
        @param bountyId the unique identifier of the bounty 
    */
    function getaddresseofBountyHunters(bytes32 bountyId) public view returns(address[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(bounties[bountyId].poster == msg.sender, "Only owner of the Bounty is allowed to call this function");
        return bounties[bountyId].bountyHuntersKeys;
    }
}