// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/ILazyMinting.sol";
import "hardhat/console.sol";

contract LazyMintNFT is
    ILazyMinting,
    ERC1155,
    EIP712,
    AccessControl
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string private constant SIGNING_DOMAIN = "Xenotype";
    string private constant SIGNATURE_VERSION = "1";

    using ECDSA for bytes32;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address signer;

    mapping(bytes => bool) public signaturesUsed;
    mapping(uint256 => address) public creator;


    event Mint(
        address indexed creator,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    );


    constructor()
        ERC1155("XenoNFT")
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {
        
    }

    function isSigner(address account) public view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    
    function redeem(
        address minter,
        NFTVoucher memory voucher
    ) external payable {
        console.log("redeem1");
        require(signaturesUsed[voucher.signature] == false, "signature used");

        signer = _verify(voucher);
        require(signer != minter, "you cannot buy your own NFT");
        console.log("redeem5");
        console.log("redeem6");
        require(isSigner(minter) == false, "Signature Invalid");
        _setApprovalForAll(signer, minter, true);
        _mint(signer, voucher.tokenId, voucher.amount, "");
        _setURI(voucher.tokenURI);
        signaturesUsed[voucher.signature] = true;

        safeTransferFrom(signer, minter, voucher.tokenId, voucher.amount, "");

        emit Mint(signer, voucher.tokenId, voucher.price, voucher.amount);
    }

    function check(NFTVoucher memory voucher) public view returns (address) {
        return _verify(voucher);
    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    function _verify(NFTVoucher memory voucher)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }

    function _hash(NFTVoucher memory voucher) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFTVoucher(uint256 tokenId,uint256 amount,uint256 price,string tokenURI)"
                        ),
                        voucher.tokenId,
                        voucher.amount,
                        voucher.price,
                        keccak256(bytes(voucher.tokenURI))
                    )
                )
            );
    }

    function _beforeTokenMint(
        uint256 id,
        uint256 amount,
        string memory _tokenURI
    ) internal view {
        require(creator[id] == address(0), "Token is already minted");
        require(amount != 0, "Amount should be positive");
        require(bytes(_tokenURI).length > 0, "tokenURI should be set");
    }
}