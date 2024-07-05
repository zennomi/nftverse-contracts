import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS } from './constants';
import { parseUnits } from 'ethers/lib/utils';


async function main() {
    const TOKEN_ID = 10
    const PAYMENT_TOKEN = "0xbd52a62952952c1f8dff22524754b759e3301b81"
    const PRICE = parseUnits("100", 18)
    const MIN_PRICE = parseUnits("1", 18)
    const START_TIME = Math.round(Date.now() / 1000)
    const DURATION = 5 * 60

    const signers = await ethers.getSigners();

    // approve
    const nft = new ethers.Contract(MEEBITS_NFT_ADDRESS, CommonNFT__factory.abi, signers[1]) as CommonNFT

    let res = await nft.approve(MARKETPLACE_ADDRESS, TOKEN_ID)

    await res.wait()

    // list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[1]) as NFTVerseMarketplace

    await marketplace.createAuction(MEEBITS_NFT_ADDRESS, TOKEN_ID, PAYMENT_TOKEN, PRICE, MIN_PRICE, START_TIME, START_TIME + DURATION)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})