//SPDX-License-Identifier:  GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFT is ERC721URIStorage {
    uint256 private tokenId;
    address contractAddress;
    address public creator;
    address public txFeeToken;
    uint256 public txFeeAmount;
    mapping(address => bool) public excludedList;

    constructor(address marketplaceAddress)
        ERC721("mercado Tokens", "mercadoNFT")
    {
        contractAddress = marketplaceAddress;
        tokenId = 0;
    }

    function setExcluded(address excluded, bool status) external {
        require(msg.sender == creator, "only the creator");
        excludedList[excluded] = status;
    }

    function createToken(
        string memory tokenURI,
        address _txFeeToken,
        uint256 _txFeeAmount
    ) public returns (uint256) {
        //_tokenIds.increment();
        tokenId += 1;
        creator = msg.sender;
        txFeeToken = _txFeeToken;
        txFeeAmount = _txFeeAmount;
        excludedList[msg.sender] = true;
        uint256 newItemId = tokenId;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        if (excludedList[_from] == false) {
            _payTxFee(_from);
        }
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        if (excludedList[_from] == false) {
            _payTxFee(_from);
        }
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function _payTxFee(address _from) internal {
        IERC20 token = IERC20(txFeeToken);
        token.transferFrom(_from, creator, txFeeAmount);
    }
}
