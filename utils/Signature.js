const { ethers } = require("ethers");
const SIGNING_DOMAIN_NAME = "Xenotype";
const SIGNING_DOMAIN_VERSION = "1"

class SignWallet {
	constructor(contractAddress, chainId, signer) {
		this.contractAddress = contractAddress
		this.chainId = chainId
		this.signer = signer
	}

	async createVoucher(tokenId, amount, price, tokenURI) {
		// const ts = (await ethers.provider.getBlock('latest')).timestamp
		const voucher = { tokenId, amount, price, tokenURI }
		const domain = await this._signingDomain()
		const types = {
			NFTVoucher: [
				{ name: 'tokenId', type: 'uint256' },
				{ name: 'amount', type: 'uint256' },
				{ name: 'price', type: 'uint256' },
				{ name: 'tokenURI', type: 'string' },
			],
		}

		const signature = await this.signer._signTypedData(
			domain,
			types,
			voucher
		)
		return { ...voucher, signature }
	}

	async _signingDomain() {
		if (this._domain != null) {
			return this._domain
		}
		const chainId = await this.chainId
		this._domain = {
			name: SIGNING_DOMAIN_NAME,
			version: SIGNING_DOMAIN_VERSION,
			verifyingContract: this.contractAddress,
			chainId,
		}
		return this._domain
	}

	static async getSign(
		contractAddress,
		chainId,
		tokenId,
		amount,
		price,
		tokenURI
	) {
		var provider = new ethers.providers.Web3Provider(window.ethereum)

		await provider.send('eth_requestAccounts', [])
		var signer = provider.getSigner()
		await signer.getAddress()

		var lm = new SignWallet(contractAddress, chainId, signer)
		var voucher = await lm.createVoucher(
			tokenId,
			amount,
			price,
			tokenURI
		)
		return voucher
	}
}

module.exports = SignWallet;

