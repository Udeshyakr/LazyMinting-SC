// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface ILazyMinting {
    //@dev don't change the structure as it is being inherited in other contracts
    struct NFTVoucher {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        string tokenURI;
        bytes signature;
    }

    function redeem(
        address minter,
        NFTVoucher calldata voucher
    ) external payable ;
}