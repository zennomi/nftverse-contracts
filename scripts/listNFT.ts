import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS } from './constants';
import { parseUnits } from 'ethers/lib/utils';


async function main() {
    const TOKEN_ID = 1
    const PAYMENT_TOKEN = "0xbd52a62952952c1f8dff22524754b759e3301b81"
    const PRICE = parseUnits("100", 18)

    const signers = await ethers.getSigners();

    // approve
    const nft = new ethers.Contract(MEEBITS_NFT_ADDRESS, CommonNFT__factory.abi, signers[1]) as CommonNFT

    let res = await nft.approve(MARKETPLACE_ADDRESS, TOKEN_ID)

    await res.wait()

    // list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[1]) as NFTVerseMarketplace

    await marketplace.listNft(MEEBITS_NFT_ADDRESS, TOKEN_ID, PAYMENT_TOKEN, PRICE)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})