import { BigNumber } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { NFTVerseMarketplace__factory } from '../typechain';


async function main() {
  const signers = await ethers.getSigners();

  const NFTMarketplace = new NFTVerseMarketplace__factory(signers[0]);
  const platformFee = BigNumber.from(10); // 10%
  const feeRecipient = signers[0].address;
  // const nftMarketplace = await NFTMarketplace.deploy(platformFee, feeRecipient);
  const nftMarketplace = await upgrades.deployProxy(NFTMarketplace, [platformFee, feeRecipient]);
  await nftMarketplace.deployed();
  console.log('NFTVerseMarketplace deployed to: ', nftMarketplace.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;

})