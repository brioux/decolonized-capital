// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (governance/extensions/GovernorCountingSimple.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "zk-merkle-tree/contracts/ZKTree.sol";
import "./ZKTreeVote.sol";

/**
 * @dev Extension of {Governor} for count with all votes cast to 
 * a ZKTree of anonymous voter commitments with equal weight 
 *
 * _Available since v???
 */
abstract contract GovernorCountingZKVote is Governor {

    address public owner;

    struct ProposalVote {
        mapping(uint8 => uint256) supportVotes; // for given option
        uint8 lead; // current vote in the lead 
        uint256 leadVotes; // number of votes in the lead
        uint256 quorum; // number of votes for quorum
        //mapping(bytes32 => bool) hasVoted; //
        address zkTreeVote;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;

    modifier onlyProposer(uint256 proposalId) {
        require(proposalProposer(proposalId) = msgSender(), "GovernorCountingZKVote::onlyProposer: msg.sender is not the proposer");
        _;
    }

    modifier onlyPending(uint256 proposalId) {
        require(super.state == ProposalSate.pending, "GovernorCountingZKVote::onlyPending: proposal is not longer pending");
        _;
    }

    event RegisterCommitment(uint256 indexed proposal, address indexed account, uint256 indexed commitment, uint256 uniqueHash);


    /**
     * @dev See {IGovernor-COUNTING_MODE}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=candidate&quorum=spread";
    }

    /**
     * @dev See {IGovernor-hasVoted}.
     */
    /*function hasVoted(uint256 proposalId, bytes32 nullifier) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[nullifier];
    }*/

    /**
     * @dev Accessor to the internal vote counts.
     */
    function supportVotes(
        uint256 proposalId,
        uint option
    ) public view virtual returns (uint256 support) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (ZKTreeVote(proposalVote.zkTreeVote).getOptionCounter(option));
    }

    /**
     * Internal function to set proposal options
     */
    function setProposalOptions(
        uint256 proposalId, uint256 options, uint256 quorum) public 
        internal onlyProposer(proposalId) onlyPending(proposalId) {

        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        proposalVote.quorum = quorum;
    }
    function createZKTreeVote(
        uint256 proposalId,
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        uint _numOptions) public {
        ZKTreeVote public zKTreeVote;
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        zKTreeVote = new ZKTreeVote(_levels, _hasher, _verifier,_numOptions);
        proposalVote.zKTreeVote = zKTreeVote.address;
    }
    /**
     * @dev See {Governor-_quorumReached}.
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return proposalVote.quorum <= proposalVote.leadVotes;
        bool _status = true;
        return _status;
    }

    /**
     * @dev See {Governor-_voteSucceeded}. In this module, the forVotes must be strictly over the againstVotes.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return proposalVote.lead > 0;
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params
    ) internal virtual override {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        bytes32 = nullifier;
        
        assembly {
                calldatacopy(params, 4, 36)
                nullifier := mload(0x0)
        }
        proposalVote.supportVotes[support] += 1; //each nullifier gets 1 vote.
        if(proposalVote.supportVotes[support]>proposalVote.leadVotes) {
            proposalVote.lead = support;
        }else if(proposalVote.supportVotes[support]>proposalVote.leadVotes){
            proposalVote.lead = 0;
        }
    }

    function registerCommitment(
        uint256 _proposalId,
        uint256 _uniqueHash,
        uint256 _commitment
    ) external {
        require(super.validators[msg.sender], "Only validator can commit!");
        ProposalVote storage proposalVote = _proposalVotes[_proposalId];  
        require(
            !proposalVote.uniqueHashes[_uniqueHash],
            "This unique hash is already used!"
        );
        _commit(bytes32(_commitment));
        proposalVote.uniqueHashes[_uniqueHash] = true;
        emit RegisterCommitment(proposalId,msg.sender,_commitment,_uniqueHash);
    }

    function vote(
        uint _option,
        uint256 _nullifier,
        uint256 _root,
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c
    ) external {
        require(_option <= numOptions, "Invalid option!");
        _nullify(
            bytes32(_nullifier),
            bytes32(_root),
            _proof_a,
            _proof_b,
            _proof_c
        );
        optionCounter[_option] = optionCounter[_option] + 1;
    }
}
