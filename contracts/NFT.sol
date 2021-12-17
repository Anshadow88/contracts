//SPDX-License-Identifier:  GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC2981PerTokenRoyalties.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, ERC2981PerTokenRoyalties {
    uint256 private tokenIds;
    address contractAddress;
    address public creator;
    address public txFeeToken;
    uint256 public txFeeAmount;
    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;
    mapping(address => bool) public excludedList;

    constructor(address marketplaceAddress)
        ERC721("mercado Tokens", "mercadoNFT")
    {
        contractAddress = marketplaceAddress;
        tokenIds = 0;
    }

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function createToken(
        string memory _tokenURI, address _txFeeToken, uint256 _txFeeAmount) public returns (uint256) {
        tokenIds += 1; 
        uint256 newItemId = tokenIds;
        _safeMint(msg.sender, newItemId);
        creator = msg.sender;
        txFeeToken = _txFeeToken;
        txFeeAmount = _txFeeAmount;
        excludedList[msg.sender] = true;
        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    } 

    function setExcluded(address excluded, bool status) external {
    require(msg.sender == creator, 'artist only');
    excludedList[excluded] = status;
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 tokenId
  ) public override {
     require(
       _isApprovedOrOwner(_msgSender(), tokenId), 
       'ERC721: transfer caller is not owner nor approved'
     );
     if(excludedList[from] == false) {
      _payTxFee(from);
     }
     _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
   ) public override {
     if(excludedList[from] == false) {
       _payTxFee(from);
     }
     safeTransferFrom(from, to, tokenId, '');
   }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId), 
      'ERC721: transfer caller is not owner nor approved'
    );
    if(excludedList[from] == false) {
      _payTxFee(from);
    }
    _safeTransfer(from, to, tokenId, _data);
  }

  function _payTxFee(address from) internal {
    IERC20 token = IERC20(txFeeToken);
    token.transferFrom(from, creator, txFeeAmount);
  }
}
