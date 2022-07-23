
# Lazy Minting

Minting "just in time" at the moment of purchase is often called lazy minting, and it has been adopted by marketplaces like OpenSea (opens new window)to lower the barrier to entry for NFT creators by making it possible to create NFTs without any up-front costs.

```
This contract deploys an ERC1155 token, with lazy minting functionality, meaning it could mint off-chain signed nfts to buyers and send the buy price to the signer.
```

## The Redeem() function takes 2 arguments:

 - Minter - who will mint the NFT
 - NFT Voucher - An array of NFT details, w.r.t. the NFT struct in the contract

```
 - If the EIP712 based Typed Data signature is valid, then the NFT is minted and sold.
 - The Nft is minted to the off-chain by signer first to establish ownership on-chain and then it is transferred to the buyer.
 - If signature is invalid, then the transaction will be reverted.
 - The same signature cannot be used again.
 - EIP-712 based Typed Data Format is used to sign the Nft details off-chain to get the signature, and the signer is validated by the contract via using the _hashTypedDataV4() function of EIP-712 contract, which creates a bytes32 digest
 - This digest and the signature is passed to ECDSA.recover() which extracts the signer and returns its address.

```

## Creating signature on Frontend

- First, create the domain for the signature, as required by EIP-712.
```
const domain = {
    name: "Domain Signing Name, as specified in your contract.",
    version: "Domain Signing Version, as specified in your contract.",
    verifyingContract: "Address of your contract, where this signature would be validated.",
    chainId: "Chain id of the network on which contract is deployed."
};
```

- Then, create a Types object based on Typed Data Structure format, supported by EIP-712.
```
const types = {
			NFTVoucher: [
				{ name: 'tokenId', type: 'uint256' },
				{ name: 'amount', type: 'uint256' },
				{ name: 'price', type: 'uint256' },
				{ name: 'tokenURI', type: 'string' },
			],
		}
```

- Make sure you are connected to metamask and have the signer object.

```
var provider = new ethers.providers.Web3Provider(window.ethereum)

		await provider.send('eth_requestAccounts', [])
		var signer = provider.getSigner()
		await signer.getAddress()
```
