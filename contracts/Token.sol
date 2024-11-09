// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ITRC721 {
    function mint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}

contract MobileStoreToken is ITRC20 {
    string public constant name = "Mobile Store Token";
    string public constant symbol = "MST";
    uint8 public constant decimals = 6;
    
    uint256 public constant TOTAL_SUPPLY = 10_000_000 * 10**6; // 10 million tokens
    uint256 public constant GOVERNANCE_THRESHOLD = 10_000 * 10**6; // 10,000 tokens for governance
    uint256 public constant INITIAL_PRICE = 100_000; // $0.10 in smallest denomination
    
    // Tier Constants
    uint256 public constant BRONZE_TIER = 100 * 10**6;
    uint256 public constant SILVER_TIER = 500 * 10**6;
    uint256 public constant GOLD_TIER = 1000 * 10**6;
    
    address public owner;
    address public nftContract;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isKYCVerified;
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    mapping(address => StakingInfo) public stakingInfo;
    
    uint256 public proposalCount;
    uint256 private _totalSupply;
    
    struct UserInfo {
        uint256 tier;
        uint256 stakingBalance;
        uint256 lastPurchaseTime;
        address referrer;
        bool isRegistered;
        uint256 rewardPoints;
    }
    
    struct Proposal {
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 endTime;
        bool executed;
        mapping(address => bool) voted;
    }
    
    struct StakingInfo {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 rewards;
    }
    
    event TokensBurned(address indexed burner, uint256 amount);
    event StakeStarted(address indexed user, uint256 amount, uint256 duration);
    event StakeEnded(address indexed user, uint256 amount, uint256 rewards);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);
    event TierUpdated(address indexed user, uint256 newTier);
    event RewardPointsEarned(address indexed user, uint256 points);
    event NFTMinted(address indexed user, uint256 tokenId);
    event KYCStatusUpdated(address indexed user, bool status);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyKYCVerified() {
        require(isKYCVerified[msg.sender], "KYC verification required");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        _totalSupply = TOTAL_SUPPLY;
        _balances[msg.sender] = TOTAL_SUPPLY;
        
        // Initial token distribution
        uint256 publicSale = (TOTAL_SUPPLY * 40) / 100;
        uint256 rewardsPool = (TOTAL_SUPPLY * 30) / 100;
        uint256 teamAllocation = (TOTAL_SUPPLY * 15) / 100;
        uint256 marketing = (TOTAL_SUPPLY * 10) / 100;
        uint256 reserve = (TOTAL_SUPPLY * 5) / 100;
        
        // Transfer initial allocations
        _transfer(msg.sender, address(this), TOTAL_SUPPLY - publicSale); // Keep all except public sale in contract
        emit Transfer(msg.sender, address(this), TOTAL_SUPPLY - publicSale);
    }
    
    // Basic TRC20 Functions
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override onlyKYCVerified returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    // Loyalty and Rewards Functions
    function updateTier(address user) internal {
        uint256 balance = _balances[user];
        uint256 newTier;
        
        if (balance >= GOLD_TIER) {
            newTier = 3; // Gold
        } else if (balance >= SILVER_TIER) {
            newTier = 2; // Silver
        } else if (balance >= BRONZE_TIER) {
            newTier = 1; // Bronze
        }
        
        if (userInfo[user].tier != newTier) {
            userInfo[user].tier = newTier;
            emit TierUpdated(user, newTier);
        }
    }
    
    // Staking Functions
    function stake(uint256 amount, uint256 duration) public onlyKYCVerified {
        require(amount > 0, "Cannot stake 0 tokens");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(duration >= 90 days && duration <= 180 days, "Invalid duration");
        
        _transfer(msg.sender, address(this), amount);
        
        stakingInfo[msg.sender] = StakingInfo({
            amount: amount,
            startTime: block.timestamp,
            duration: duration,
            rewards: 0
        });
        
        emit StakeStarted(msg.sender, amount, duration);
    }
    
    // Governance Functions
    function createProposal(string memory description, uint256 duration) public {
        require(_balances[msg.sender] >= GOVERNANCE_THRESHOLD, "Insufficient tokens for proposal");
        
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = description;
        newProposal.endTime = block.timestamp + duration;
        
        emit ProposalCreated(proposalCount, description);
    }
    
    function vote(uint256 proposalId, bool support) public onlyKYCVerified {
        require(_balances[msg.sender] >= GOVERNANCE_THRESHOLD, "Insufficient tokens for voting");
        require(!hasVoted[msg.sender][proposalId], "Already voted");
        require(block.timestamp < proposals[proposalId].endTime, "Voting ended");
        
        if (support) {
            proposals[proposalId].forVotes += _balances[msg.sender];
        } else {
            proposals[proposalId].againstVotes += _balances[msg.sender];
        }
        
        hasVoted[msg.sender][proposalId] = true;
        emit Voted(proposalId, msg.sender, support);
    }
    
    // NFT Integration
    function setNFTContract(address _nftContract) public onlyOwner {
        nftContract = _nftContract;
    }
    
    function mintNFT(uint256 tokenId) public {
        require(_balances[msg.sender] >= 1000 * 10**6, "Insufficient tokens for NFT");
        ITRC721(nftContract).mint(msg.sender, tokenId);
        emit NFTMinted(msg.sender, tokenId);
    }
    
    // KYC/AML Functions
    function updateKYCStatus(address user, bool status) public onlyOwner {
        isKYCVerified[user] = status;
        emit KYCStatusUpdated(user, status);
    }
    
    // Internal transfer function
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(_balances[sender] >= amount, "Transfer amount exceeds balance");
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        updateTier(sender);
        updateTier(recipient);
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}