import { ethers } from 'hardhat';
import { CommonNFT, CommonNFT__factory } from '../../typechain';
import { MEEBITS_NFT_ADDRESS } from '../constants';

// const ids: number[] = [2, 3595, 7556, 18854, 19154, 11689, 5036, 8405, 13625, 13677, 2328, 9817, 6943, 17167, 4537, 5451, 314]
const ids: number[] = [2, 3595, 7556, 18854, 19154, 11689, 5036, 8405, 13625, 13677, 2328, 9817, 6943, 17167, 4537, 5451, 314]

async function main() {
    const signers = await ethers.getSigners();
    const RECIEVER_ADDRESS = signers[1].address

    console.info("RECIEVER_ADDRESS: ", RECIEVER_ADDRESS)

    for (const id of ids) {
        const URI = `https://meebits.larvalabs.com/meebit/${id}`

        const nft = new ethers.Contract(MEEBITS_NFT_ADDRESS, CommonNFT__factory.abi, signers[1]) as CommonNFT

        await nft.safeMint(RECIEVER_ADDRESS, URI)

        console.log(URI)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})