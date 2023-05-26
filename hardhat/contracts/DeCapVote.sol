// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DeCapVote is ERC721, ERC721Votes, AccessControl{
    using Counters for Counters.Counter;
    bytes32 public constant VOTER_REGISTRAR = keccak256("VOTER_REGISTRAR");

    struct TokenDetails {
        /*uint256 tokenId;
        address issuedBy;
        address issuedTo;
        uint256 dateCreated;*/
        bytes32 hash;
    }

    mapping(uint256 => TokenDetails) public _tokenDetails;
    mapping(bytes32 => uint256) public _tokenId;

    bool public limitedMode; // disables some features
    bool public openVote; // TODO Warning!!! this should be droped. Setting to true allows anyone to issue receive voting tokens

    // Counts number of unique token IDs (auto-incrementing)
    Counters.Counter public _numOfUniqueTokens;

    event AssignRegistrar(address indexed account);
    event RevokeRegistrar(address indexed account);

    constructor(address _admin) ERC721("DeCapVote", "DCV") EIP712("",""){
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(VOTER_REGISTRAR, _admin);
        openVote = true;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DeCap::onlyAdmin: msg.sender not the admin");
        _;
    }

    modifier onlyRegistrar() {
        require(hasRole(VOTER_REGISTRAR, msg.sender) || openVote, "DeCap::onlyAdmin: msg.sender not the registrar");
        _;
    }
    modifier onlyValidVoter(address _voter) {
        require(super.balanceOf(_voter)<1 && limitedMode || openVote, "DeCap::registerVoter: _voter is already registered");
        _;
    }
    modifier onlyValidHash(bytes32 _hash) {
        require(_tokenId[_hash]==0,
           "DeCap::registerVoter: _hash is already registered to a token");
        _;
    }

    /**
     * @dev returns number of unique tokens
     */
    function getNumOfUniqueTokens() public view returns (uint256) {
        return _numOfUniqueTokens.current();
    }

    function getTokenId(bytes32 _hash) public view returns (uint256) {
        return _tokenId[_hash];
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev turns off or on limited mode
     * @param _limitedMode boolean value
     */
    function setLimitedMode(bool _limitedMode) external onlyAdmin {
        limitedMode = _limitedMode;
    }

    function setopenVote(bool _openVote) external onlyAdmin {
        openVote = _openVote;
    }

    function assignRegistrar(address _registrar) onlyAdmin external{
        require(!hasRole(VOTER_REGISTRAR, _registrar),
            "DeCap::assignRegistrar: _registrar already assigned");
        //_setupRole(VOTER_REGISTRAR, _registrar);
        emit AssignRegistrar(_registrar);
    }

    function revokeRegistrar(address _registrar) onlyAdmin external{
        revokeRole(VOTER_REGISTRAR, _registrar);
        emit RevokeRegistrar(_registrar);
    }

    function issueVote(address _voter, bytes32 _hash) external onlyRegistrar onlyValidVoter(_voter) onlyValidHash(_hash) {
        _numOfUniqueTokens.increment();
        // store token details
        TokenDetails storage tokenInfo = _tokenDetails[_numOfUniqueTokens.current()];
        tokenInfo.hash = _hash;
        _tokenId[_hash] = _numOfUniqueTokens.current();
        //tokenInfo.issuedBy = msg.sender;
        //tokenInfo.issuedTo = _voter;
        //tokenInfo.dateCreated = block.timestamp;
        _mint(_voter, _numOfUniqueTokens.current());
    }

    function revokeVote(address _voter, uint256 tokenId) external onlyRegistrar{
        require(super.ownerOf(tokenId)==_voter,
           "DeCap::registerVoter: _voter not registered to this vote");
        super._burn(tokenId);
    }

    /**
     * @dev hook to prevent transfers from non-admin account if limitedMode is on
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId, 
        uint256 batchSize
    ) internal virtual override{
        // TO-DO this could be set as a modifier ...
        require(
            (!limitedMode || from == address(0) || to == address(0)),
            "DeCap::_beforeTokenTransfer: vote transfers disabled in limited mode (only issue and revoke)"
        );
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }


    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC721)
    {
        super._mint(to, amount);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721)
    {
        super._burn(tokenId);
    }

    // Overrides IERC6372 functions to make the token & governor timestamp-based

    function clock() public view returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public pure returns (string memory) {
        return "mode=timestamp";
    }
}