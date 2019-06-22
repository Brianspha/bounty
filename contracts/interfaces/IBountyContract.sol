pragma solidity >= 0.5 .0;

/**
 * @dev Interface of the BountyContract
 */

interface IBountyContract {
    function updateUserRanking(uint256 rank, address user) external returns(bool);

    function userExists() external view returns(bool);

    function suspendUser(address user) external returns(bool);

    function addBounty(bytes calldata title, bytes calldata description, bytes calldata category, uint endDate, uint difficulty) external payable;

    function addBountyOfferToken(bytes calldata title, bytes calldata description, bytes calldata category, uint endDate, uint difficulty, address tokenAddress, uint256 amount) external returns(bool);

    function bountyExists(bytes32 bountyId) external view returns(bool);

    function proposeSolution(bytes32 bountyId, bytes calldata solutionHash) external returns(bool);

    function rejectSolution(bytes32 bountyId) external returns(bool);

    function acceptSolution(bytes32 bountyId, address bountyHunterAddress) external returns(bool);

    function bountyExpired(bytes32 bountyId) external view returns(bool);

    function pauseBounty(bytes32 bountyId) external returns(bool);

    function endDispute(bytes32 bountyId) external returns(bool);

    function getUserPostedBounties() external view returns(bytes32[] memory);

    function getUserRejectedBounties() external view returns(bytes32[] memory);

    function getUserAcceptedBounties() external view returns(bytes32[] memory);

    function getaddresseofBountyHunters(bytes32 bountyId) external view returns(address[] memory);
    /*=================================== @dev structs definition code start===================================*/
    /**
    @dev User struct represents a user who eitheir posts bounties or a bounty seeker
    @atr id represents the address of the User
    @atr earnings represents the total earnings by User
    @atr Bounties represents the ids of all the bounties the user has completed
    @active indicates if the user is active or not
    @atr suspended indicates if the user is suspended or not
    @atr ranking indicates the users ranking
    @atr indicates if a user has been punished or not
    */
    struct User {
        address id;
        uint256 earnings;
        bytes32[] acceptedBounties;
        bytes32[] rejectedBounties;
        bytes32[] postedBounties;
        bool active;
        bool suspended;
        uint256 ranking;
        bool punished;
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
    @atr BountyHunters addresses of all the Bounty Hunters who have submitted solutions
    @atr proposedSolutions the hash to the solution stored on IPFS
    @atr winner represents the Bounty whos solution was accepted
    @atr isToken states if the token uses ERC720 tokens for rewarding the bountyHunter
    @notice poster atr cannot be used as an id as user may have multiple bounties posted looping may be costly
    *A Bounty hunter can post as many solutions as possible only the lastest solution will be accepted
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
        address[] bountyHunters;
        Token tokenPayment;
        address winner;
        bool paused;
        bool isToken;
    }
    /**
    *@dev represents a token as well as the number of pledged tokens
    @atr tokenAddress the address of the token
    @atr amount the amount of tokens to transfer when the bounty expires
    @atr active indicates if a token has been pledged as payment or not
    */
    struct Token {
        address tokenAddress;
        uint256 amount;
        bool active;
    }
    /*=================================== @dev event definition code start===================================*/
    /**
     *@dev bountyIdLogger used to emit the id of a submitted bounty to the front end
     */
    event bountyIdLogger(bytes32 Id);

}