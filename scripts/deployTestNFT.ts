import { ethers } from 'hardhat';
import { CommonNFT__factory } from '../typechain';


async function main() {
    const signers = await ethers.getSigners();

    const CommonNFT = new CommonNFT__factory(signers[0]);
    const nft = await CommonNFT.deploy(signers[0].address);
    await nft.deployed();
    console.log('Test NFT deployed to: ', nft.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;

})