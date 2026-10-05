// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AssignmentSubmission
 * @notice Students submit the hash (fingerprint) of their assignment file.
 *         The contract records the submission time on-chain.
 * @dev The file itself is NEVER stored on-chain, only its bytes32 hash.
 */
contract AssignmentSubmission {
    // ---------------------------------------------------------------
    // STATE VARIABLES
    // ---------------------------------------------------------------

    /// @notice Teacher / admin address (the account that deployed the contract)
    address public owner;

    /// @notice true = students can submit, false = submissions closed
    bool public submissionsOpen;

    /// @notice Deadline as a Unix timestamp (seconds). 0 means "no deadline".
    uint256 public deadline;

    /// @dev One submission record: the hash and the time it was stored
    struct Submission {
        bytes32 assignmentHash;
        uint256 timestamp;
    }

    /// @dev student address => their submission
    mapping(address => Submission) private submissions;

    /// @notice student address => has this student already submitted?
    mapping(address => bool) public hasSubmitted;

    /// @dev hash => student who submitted it (used to block duplicate hashes)
    mapping(bytes32 => address) private hashToStudent;

    /// @dev list of all students who submitted (so the teacher can look them up)
    address[] private studentList;

    // ---------------------------------------------------------------
    // EVENTS (logs that Remix / Etherscan / frontends can read)
    // ---------------------------------------------------------------

    event AssignmentSubmitted(
        address indexed student,
        bytes32 indexed assignmentHash,
        uint256 timestamp
    );
    event DeadlineUpdated(uint256 newDeadline);
    event SubmissionsStatusChanged(bool isOpen);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // ---------------------------------------------------------------
    // ACCESS CONTROL
    // ---------------------------------------------------------------

    /// @dev Restricts a function to the teacher (owner) only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    // ---------------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------------

    /// @notice The deployer becomes the owner; submissions start open
    constructor() {
        owner = msg.sender;
        submissionsOpen = true;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ---------------------------------------------------------------
    // STUDENT FUNCTION
    // ---------------------------------------------------------------

    /**
     * @notice Submit the hash of your assignment. Allowed only once per student.
     * @param _hash The bytes32 (SHA-256) hash of the assignment file
     */
    function submitAssignment(bytes32 _hash) external {
        require(submissionsOpen, "Submissions are closed");
        require(
            deadline == 0 || block.timestamp <= deadline,
            "Deadline has passed"
        );
        require(_hash != bytes32(0), "Hash cannot be empty");
        require(!hasSubmitted[msg.sender], "You have already submitted");
        require(
            hashToStudent[_hash] == address(0),
            "This hash was already submitted"
        );

        submissions[msg.sender] = Submission({
            assignmentHash: _hash,
            timestamp: block.timestamp
        });
        hasSubmitted[msg.sender] = true;
        hashToStudent[_hash] = msg.sender;
        studentList.push(msg.sender);

        emit AssignmentSubmitted(msg.sender, _hash, block.timestamp);
    }

    // ---------------------------------------------------------------
    // VIEW FUNCTIONS (free to call, no gas)
    // ---------------------------------------------------------------

    /// @notice Get a student's stored hash and submission time
    function getSubmission(address _student)
        external
        view
        returns (bytes32 assignmentHash, uint256 timestamp)
    {
        require(hasSubmitted[_student], "No submission found");
        Submission memory s = submissions[_student];
        return (s.assignmentHash, s.timestamp);
    }

    /// @notice Check if a hash matches what the student submitted
    function verifySubmission(address _student, bytes32 _hash)
        external
        view
        returns (bool)
    {
        return hasSubmitted[_student] && submissions[_student].assignmentHash == _hash;
    }

    /// @notice How many students have submitted
    function getStudentCount() external view returns (uint256) {
        return studentList.length;
    }

    /// @notice Get the address of the student at a given position (0, 1, 2...)
    function getStudentAt(uint256 _index) external view returns (address) {
        require(_index < studentList.length, "Index out of range");
        return studentList[_index];
    }

    // ---------------------------------------------------------------
    // OWNER (TEACHER) FUNCTIONS
    // ---------------------------------------------------------------

    /// @notice Open or close submissions
    function setSubmissionsOpen(bool _open) external onlyOwner {
        submissionsOpen = _open;
        emit SubmissionsStatusChanged(_open);
    }

    /// @notice Set a deadline (Unix time in seconds). Use 0 to remove the deadline.
    function setDeadline(uint256 _newDeadline) external onlyOwner {
        require(
            _newDeadline == 0 || _newDeadline > block.timestamp,
            "Deadline must be in the future"
        );
        deadline = _newDeadline;
        emit DeadlineUpdated(_newDeadline);
    }

    /// @notice Give ownership to another address
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
