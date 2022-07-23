<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signing Voucher</title>
    <script charset="utf-8"
        src="https://cdn.ethers.io/scripts/ethers-v4.min.js"
        type="text/javascript">
    </script> 
</head>
<body>
<script type ="text/javascript">
    const SIGNING_DOMAIN_NAME = "SOLULAB";
    const SIGNING_DOMAIN_VERSION = "1"
    
    class SignWallet{
    
        constructor(contractAddress, chainId, signer){
            this.contractAddress = contractAddress;
            this.chainId = chainId;
            this.signer = signer;
        }
    
        async createSignature(tokenId, uri, minPrice = 0){
            const obj = {tokenId, uri, minPrice}
            const domain = await this._signingDomain()
            const types = {
                WEB3Struct: [
                    { name: "tokenId", type: "uint256"},
                    { name: "uri", type: "string"},
                    { name: "minPrice", type: "uint256"},
    
                ]
            }
    
            const signature = await this.signer._signTypedData(domain, types, obj)
            return { ...obj, signature }
        }
    
        async _signingDomain(){
            if(this._domain != null){
                return this._domain
            }
            const chainId = await this.chainId
            this._domain = {
                name:SIGNING_DOMAIN_NAME,
                version:SIGNING_DOMAIN_VERSION,
                verifyingContract:this.contractAddress,
                chainId,
            }
            return this._domain
        }
    
        static async getSign(contractAddress, chainId, tokenId, uri, minPrice){
            var provider = new ethers.providers.Web3Provider(window.ethereum)
    
            await provider.send("eth_requestAccounts", []);
            var signer = provider.getSigner();
            await signer.getAddress()
    
            var lm = new SignWallet(contractAddress, chainId, signer, tokenId, uri, minPrice)
            var voucher = await lm.createSignature(tokenId, uri, minPrice)
            return voucher
        }
    }
        
</script>

</body>
</html>