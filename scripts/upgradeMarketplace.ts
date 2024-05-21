import { BigNumber } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { NFTVerseMarketplace__factory } from '../typechain';
import { MARKETPLACE_ADDRESS } from './constants';


async function main() {
  const signers = await ethers.getSigners();

  const NFTMarketplace = new NFTVerseMarketplace__factory(signers[0]);
  const nftMarketplace = await upgrades.upgradeProxy(MARKETPLACE_ADDRESS, NFTMarketplace);
  console.log('NFTVerseMarketplace upgraded');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;

})