import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory, ERC20, ERC20__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, MEEBITS_NFT_ADDRESS, PAYMENT_TOKEN } from './constants';
import { parseUnits } from 'ethers/lib/utils';


async function main() {
    const TOKEN_ID = 10
    const PRICE = parseUnits("90", 18)
    const NFT_ADDRESS = MEEBITS_NFT_ADDRESS

    const signers = await ethers.getSigners();

    const buyer = signers[1]

    // approve
    const erc20 = new ethers.Contract(PAYMENT_TOKEN, CommonNFT__factory.abi, buyer) as ERC20

    let res = await erc20.approve(MARKETPLACE_ADDRESS, PRICE)

    await res.wait()

    // list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, buyer) as NFTVerseMarketplace

    await marketplace.offerNFT(NFT_ADDRESS, TOKEN_ID, PRICE)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})