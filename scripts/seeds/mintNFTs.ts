import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory } from '../../typechain';
import SeedingNFTs from "../data/SeedingNFTs.json"

async function main() {
    const NFT_ADDRESS = "0x6CAFc373A6C5F1428fC4008B267286CeffB31bb8"
    const RECIEVER_ADDRESS = "0x08207C01616d9b383058cbd27Eb40B5ddcB0F811"

    const signers = await ethers.getSigners();
    for (const seedingNFT of SeedingNFTs) {
        const URI = "ipfs://" + seedingNFT.metadataIpfsHash

        const nft = new ethers.Contract(NFT_ADDRESS, CommonNFT__factory.abi, signers[0]) as CommonNFT

        await nft.safeMint(RECIEVER_ADDRESS, URI)

        console.log(URI)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})