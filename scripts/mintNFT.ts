import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory } from '../typechain';


async function main() {
    const NFT_ADDRESS = "0x6CAFc373A6C5F1428fC4008B267286CeffB31bb8"
    const RECIEVER_ADDRESS = "0x08207C01616d9b383058cbd27Eb40B5ddcB0F811"
    const URI = "ipfs://QmXK5ZAgiM5pQHrD9P6TiP6EGP4nBHSFJz7TdYDAP3vS5v"

    const signers = await ethers.getSigners();
    const nft = new ethers.Contract(NFT_ADDRESS, CommonNFT__factory.abi, signers[0]) as CommonNFT

    await nft.safeMint(RECIEVER_ADDRESS, URI)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})