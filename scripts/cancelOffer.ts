import { ethers } from 'hardhat';
import { NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS } from './constants';


async function main() {
    const TOKEN_ID = 10
    const NFT_ADDRESS = MEEBITS_NFT_ADDRESS

    const signers = await ethers.getSigners();

    // cancel offer
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[1]) as NFTVerseMarketplace

    await marketplace.cancelOfferNFT(NFT_ADDRESS, TOKEN_ID)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})