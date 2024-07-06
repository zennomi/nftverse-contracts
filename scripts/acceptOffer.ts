import { ethers } from 'hardhat';
import { NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS } from './constants';


async function main() {
    const TOKEN_ID = 10
    const NFT_ADDRESS = MEEBITS_NFT_ADDRESS

    const signers = await ethers.getSigners();
    const buyer = signers[1]
    const seller = signers[0]

    // cancel offer
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, seller) as NFTVerseMarketplace

    await marketplace.acceptOfferNFT(NFT_ADDRESS, TOKEN_ID, buyer.address)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})