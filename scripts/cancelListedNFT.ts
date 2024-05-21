import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, NFT_ADDRESS } from './constants';


async function main() {
    const TOKEN_ID = 12

    const signers = await ethers.getSigners();

    // cancel list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[0]) as NFTVerseMarketplace

    await marketplace.cancelListedNFT(NFT_ADDRESS, TOKEN_ID)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})