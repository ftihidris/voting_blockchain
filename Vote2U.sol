// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


contract Testing {
    address public immutable owner;
    string public electionName;
    uint256 public electionStartTime;
    uint256 public electionEndTime;
    bool public electionEnded;

    // A struct representing a candidate in the election
    struct Candidate {
        string id; 
        string name; 
        string course; 
        uint voteCount; 
    }

    // A struct representing a voter in the election
    struct Voter {
        string id;
        bool authorised; 
        bool voted; 
        bytes32 voteHash; 
    }
   
    mapping(address => Voter) public voters; // A mapping of addresses to voters
    mapping(string => bool) public studentIdExists; // A mapping of student IDs to a boolean indicating if the student ID exists
    mapping(string => bool) public candidateIdExists; // A mapping of student IDs to a boolean indicating if the student ID exists
    mapping(string => Candidate) public candidates; // An array of candidates in the election
    uint public totalVotes;// The total number of votes in the election
    uint public numCandidatesToWin; // The number of candidates required to win the election
    uint public maxCandidatesPerVote;// The maximum number of candidates a voter can vote for per election
    uint public numCandidates; // The number of candidates in the election
    event VoteCast(address voter, string[] candidateIds); // Event emitted when a vote is 
    uint public totalVoters; // New variable to count total voters

    // A modifier that restricts the function to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Testing: Only owner can call this function");
        _;
    }

    // A modifier that restricts the function to only before the election ends
    modifier onlyBeforeElectionEnd() {
        require(!electionEnded, "Testing: Election has ended");
        _;
    }

    // The constructor function that initializes the contract
    constructor(string memory _electionName, uint _numCandidatesToWin, uint _maxCandidatesPerVote) {
        owner = msg.sender;
        electionName = _electionName;
        electionStartTime = block.timestamp;
        numCandidatesToWin = _numCandidatesToWin;
        maxCandidatesPerVote = _maxCandidatesPerVote;
    }

    // A function that adds a candidate to the election
    function addCandidate(string memory _candidateId, string memory _name, string memory _course) public onlyOwner onlyBeforeElectionEnd {
        require(!candidateIdExists[_candidateId], "Testing: Student ID already registered");
        candidates[_candidateId] = Candidate(_candidateId, _name, _course, 0);
        candidateIdExists[_candidateId] = true;
        numCandidates += 1;
    }

    // A function that adds a voter to the election
    function addVoter(address _voterAddress, string memory _studentId) public onlyOwner onlyBeforeElectionEnd {
        require(!studentIdExists[_studentId], "Testing: Student ID already registered");
        voters[_voterAddress].authorised = true;
        voters[_voterAddress].voted = false;
        studentIdExists[_studentId] = true;
        totalVoters += 1;
    }

    // A function that verifies if a voter is eligible to vote
    function verifyVoter(string memory _studentId) public view returns (bool) {
        require(studentIdExists[_studentId], "Student ID does not exist");
        require(voters[msg.sender].authorised, "Voter is not authorised");
        require(!electionEnded, "Election has ended");
        return true;
    }


    // A function that checks if a student ID exists
    function isEligibleVoter(string memory _studentId) public view returns (bool) {
        return studentIdExists[_studentId];
    }
    
    // A function that to count the total number of voter
    function getTotalVoters() public view returns (uint) {
        return totalVoters;
    }

    // A function that allows a voter to cast their vote
    function vote(string[] memory _candidateIds) public {
        require(voters[msg.sender].authorised, "Testing: Not an authorised voter");
        require(!voters[msg.sender].voted, "Testing: Already voted");
        require(_candidateIds.length <= maxCandidatesPerVote, "Testing: Exceeded maximum candidates per vote");

        // Create a string representation of the vote data
        string memory voteData = "";
        for (uint i = 0; i < _candidateIds.length; i++) {
            voteData = string(abi.encodePacked(voteData, _candidateIds[i]));
        }

        // Hash the vote data using SHA256
        bytes32 voteHash = sha256(abi.encodePacked(voteData));

        // Store the vote hash
        voters[msg.sender].voteHash = voteHash;

        for (uint i = 0; i < _candidateIds.length; i++) {
            string memory _candidateId = _candidateIds[i];
            require(candidateIdExists[_candidateId],  "Testing: Invalid candidate ID");
            candidates[_candidateId].voteCount += 1;
            totalVotes += 1;
        }

        voters[msg.sender].voted = true;

        // Emit the VoteCast event
        emit VoteCast(msg.sender, _candidateIds);
    }

    // Function to verify a vote using the stored hash
    function verifyVote(address _voter, string[] memory _candidateIds) public view returns (bool) {
        string memory voteData = "";
        for (uint i = 0; i < _candidateIds.length; i++) {
            voteData = string(abi.encodePacked(voteData, _candidateIds[i]));
        }

        bytes32 voteHash = sha256(abi.encodePacked(voteData));
        return voteHash == voters[_voter].voteHash;
    }


    // A function that returns the number of candidates in the election
    function getNumCandidates() public view returns (uint) {
        return numCandidates;
    }

    // A function that returns information about a candidate
    function getCandidateInfo(string memory candidateId) public view returns (string memory, string memory, uint) {
        require(candidateIdExists[candidateId], "Testing: Invalid candidate ID");
        return (candidates[candidateId].name, candidates[candidateId].course, candidates[candidateId].voteCount);
    }

    // A function that returns the number of votes a candidate has received
    function getCandidateVoteCount(string memory candidateId) public view returns (uint) {
        require(candidateIdExists[candidateId], "Testing: Invalid candidate ID");
        return candidates[candidateId].voteCount;
    }
    
    // Function to check if a candidate is registered
    function isCandidateRegistered(string memory _candidateId) public view returns (bool) {
      return candidateIdExists[_candidateId];
    }


    // A function that returns the total number of votes in the election
    function getTotalVotes() public view returns (uint) {
        return totalVotes;
    }

    // A function that returns the number of candidates required to win the election
    function getNumCandidatesToWin() public view returns (uint) {
        return numCandidatesToWin;
    }

    // A function that returns the maximum number of candidates a voter can vote for per election
    function getMaxCandidatesPerVote() public view returns (uint) {
        return maxCandidatesPerVote;
    }

    // A function that returns the election name
    function getElectionName() public view returns (string memory) {
        return electionName;
    }

    // A function that returns the election start time
    function getElectionStartTime() public view returns (uint256) {
        return electionStartTime;
    }

    // A function that returns the election end time
    function getElectionEndTime() public view returns (uint256) {
        return electionEndTime;
    }

    // A function that returns the election end status
    function getElectionEnded() public view returns (bool) {
        return electionEnded;
    }

    // A function that ends the election
    function endElection() public onlyOwner {
        electionEnded = true;
    }
}
