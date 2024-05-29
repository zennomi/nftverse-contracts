import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory } from '../../typechain';
import { LAMBORGHINI_NFT_ADDRESS } from '../constants';

async function main() {
    const signers = await ethers.getSigners();
    const RECIEVER_ADDRESS = "0x2D3717e7F56be2E0234Cec04176c24d0465475Dd"

    console.info("RECIEVER_ADDRESS: ", RECIEVER_ADDRESS)

    for (let id = 1; id <= 12; id++) {
        const URI = `https://nftverse-backend.zenno.moe/static/lamborghini/metadata/${id}.json`

        const nft = new ethers.Contract(LAMBORGHINI_NFT_ADDRESS, CommonNFT__factory.abi, signers[0]) as CommonNFT

        await nft.safeMint(RECIEVER_ADDRESS, URI)

        console.log(URI)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})