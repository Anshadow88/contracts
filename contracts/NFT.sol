//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address contractAddress;
    address public creator;
    address public txFeeToken;
    uint256 public txFeeAmount;
    mapping(address => bool) public excludedList;

    constructor(address marketplaceAddress)
        ERC721("mercado Tokens", "mercadoNFT")
    {
        contractAddress = marketplaceAddress;
    }

    function setExcluded(address excluded, bool status) external {
        require(msg.sender == creator, "only the creator");
        excludedList[excluded] = status;
    }

    function createToken(
        string memory tokenURI,
        address _creator,
        address _txFeeToken,
        uint256 _txFeeAmount
    ) public returns (uint256) {
        _tokenIds.increment();
        creator = _creator;
        txFeeToken = _txFeeToken;
        txFeeAmount = _txFeeAmount;
        excludedList[_creator] = true;
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        if (excludedList[from] == false) {
            _payTxFee(from);
        }
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        if (excludedList[from] == false) {
            _payTxFee(from);
        }
        _safeTransfer(from, to, tokenId, _data);
    }

    function _payTxFee(address from) internal {
        IERC20 token = IERC20(txFeeToken);
        token.transferFrom(from, creator, txFeeAmount);
    }
}
