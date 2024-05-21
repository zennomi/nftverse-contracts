import { ethers } from 'hardhat';
import { NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS, PAYMENT_TOKEN } from './constants';


async function main() {
    const signers = await ethers.getSigners();
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[0]) as NFTVerseMarketplace

    await marketplace.addPayableToken(PAYMENT_TOKEN,)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})