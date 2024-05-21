import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory, ERC20, ERC20__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, NFT_ADDRESS, PAYMENT_TOKEN } from './constants';
import { parseUnits } from 'ethers/lib/utils';


async function main() {
    const TOKEN_ID = 19
    const PRICE = parseUnits("100", 18)

    const signers = await ethers.getSigners();

    const buyer = signers[1]

    // approve
    const erc20 = new ethers.Contract(PAYMENT_TOKEN, CommonNFT__factory.abi, buyer) as ERC20

    let res = await erc20.approve(MARKETPLACE_ADDRESS, PRICE)

    await res.wait()

    // list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, buyer) as NFTVerseMarketplace

    await marketplace.buyNFT(NFT_ADDRESS, TOKEN_ID, PAYMENT_TOKEN, PRICE)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})