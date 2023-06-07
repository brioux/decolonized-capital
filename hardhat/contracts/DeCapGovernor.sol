// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
//import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract DeCapGovernor is ZKTree, Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
//, GovernorTimelockControl {

    struct ProposalDetails {
        address proposer;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        mapping(address => Receipt) receipts;
        bytes32 descriptionHash;
    }

    mapping(uint256 => ProposalDetails) private _proposalDetails;
    
    mapping(address => bool) public validators;

    constructor(IVotes _token
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier)
        Governor("DeCapGovernor")
        GovernorVotes(_token)
        GovernorSettings(1, 108800, 0)
        GovernorVotesQuorumFraction(4)
    //, TimelockController _timelock )
    //,uint256 _delay, uint256 _period )
    //
    //GovernorTimelockControl(_timelock)
    {
        owner = msg.sender;
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        pure virtual
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return 1 days;
        //return super.votingDelay();
    }

    function votingPeriod()
        public
        pure virtual
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return 1 weeks;
        //return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }



    // ============================================== Proposal lifecycle ==============================================
    /**
     * @dev See {IGovernor-propose}.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        uint8 options,
        uint256 quorum
    ) public virtual override(IGovernor, Governor) returns (uint256) {
        // Stores the proposal details (if not already present) and executes the propose logic from the core.
        _storeProposal(_msgSender(), targets, values, new string[](calldatas.length), calldatas, description);
        
        return super.propose(targets, values, calldatas, description);
    }

    /**
     * @dev See {IGovernorCompatibilityBravo-propose}.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description,
        uint8 options,
        uint256 quorum
    ) public virtual override returns (uint256) {
        require(signatures.length == calldatas.length, "GovernorBravo: invalid signatures length");
        // Stores the full proposal and fallback to the public (possibly overridden) propose. The fallback is done
        // after the full proposal is stored, so the store operation included in the fallback will be skipped. Here we
        // call `propose` and not `super.propose` to make sure if a child contract override `propose`, whatever code
        // is added there is also executed when calling this alternative interface.
        _storeProposal(_msgSender(), targets, values, signatures, calldatas, description);
        return super.propose(targets, values, _encodeCalldata(signatures, calldatas), description);
    }

    /**
     * @dev Store proposal metadata (if not already present) for later lookup.
     */
    function _storeProposal(
        address proposer,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private {
        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = hashProposal(targets, values, _encodeCalldata(signatures, calldatas), descriptionHash);

        ProposalDetails storage details = _proposalDetails[proposalId];

        if (details.descriptionHash == bytes32(0)) {
            details.proposer = proposer;
            details.targets = targets;
            details.values = values;
            details.signatures = signatures;
            details.calldatas = calldatas;
            details.descriptionHash = descriptionHash;
        }
    }

    function registerValidator(address _validator) external {
        require(msg.sender == owner, "Only owner can add validator!");
        validators[_validator] = true;
    }

    function unRegisterValidator(address _validator) external {
        require(msg.sender == owner, "Only owner can remove validator!");
        validators[_validator] = false;
    }

/*

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }


    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
*/
}
