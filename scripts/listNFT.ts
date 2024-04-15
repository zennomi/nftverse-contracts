import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory, NFTVerseMarketplace, NFTVerseMarketplace__factory } from '../typechain';


async function main() {
    const NFT_ADDRESS = "0x6CAFc373A6C5F1428fC4008B267286CeffB31bb8"
    const TOKEN_ID = 0
    const PAYMENT_TOKEN = "0xbd52a62952952c1f8dff22524754b759e3301b81"
    const PRICE = BigInt(100)

    const MARKETPLACE_ADDRESS = "0xA3351471aAfc4870704c3E7BE0a2c4BD76436520"

    const signers = await ethers.getSigners();

    // approve
    const nft = new ethers.Contract(NFT_ADDRESS, CommonNFT__factory.abi, signers[0]) as CommonNFT

    let res = await nft.approve(MARKETPLACE_ADDRESS, TOKEN_ID)

    await res.wait()

    // list
    const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, NFTVerseMarketplace__factory.abi, signers[0]) as NFTVerseMarketplace

    await marketplace.listNft(NFT_ADDRESS, TOKEN_ID, PAYMENT_TOKEN, PRICE)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})