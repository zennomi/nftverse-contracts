import { ethers } from 'hardhat';
import { CommonNFT__factory, ERC20, NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS, PAYMENT_TOKEN } from './constants';
import { parseUnits } from 'ethers/lib/utils';


async function main() {
    const TOKEN_ID = 10
    const NFT_ADDRESS = MEEBITS_NFT_ADDRESS
    const PRICE = parseUnits("101", 18)

    const signers = await ethers.getSigners();

    // approve
    const erc20 = new ethers.Contract(PAYMENT_TOKEN, CommonNFT__factory.abi, signers[0]) as ERC20

    let res = await erc20.approve(MARKETPLACE_ADDRESS, PRICE)

    await res.wait()

    console.info("Approved")

    // bid place
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[0]) as NFTVerseMarketplace

    await marketplace.bidPlace(NFT_ADDRESS, TOKEN_ID, PRICE)

    console.info("Placed")
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})