import { ethers } from 'hardhat';
import { NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';


async function main() {
    const MARKETPLACE_ADDRESS = "0xA3351471aAfc4870704c3E7BE0a2c4BD76436520"
    const PAYMENT_TOKEN = "0xbd52a62952952c1f8dff22524754b759e3301b81"

    const signers = await ethers.getSigners();
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[0]) as NFTVerseMarketplace

    await marketplace.addPayableToken(PAYMENT_TOKEN,)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})