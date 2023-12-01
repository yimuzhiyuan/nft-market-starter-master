const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Market", function () {
  let usdt, market, myNft, account1, account2;

  beforeEach(async () => {
    [account1, account2] = await ethers.getSigners();
    const USDT = await ethers.getContractFactory("cUSDT");
    usdt = await USDT.deploy();
    const MyNFT = await ethers.getContractFactory("NFTM");
    myNft = await MyNFT.deploy(account1.address);
    const Market = await ethers.getContractFactory("Market");
    market = await Market.deploy(usdt.target, myNft.target);
    await myNft.safeMint(account1.address);
    await myNft.safeMint(account1.address);
    await usdt.transfer(account2.address, "100000000000000000000000000");
    await usdt.connect(account2).approve(market.target, "100000000000000000000000000");
  });

it('its erc20 address should be usdt', async function() {
  expect(await market.erc20()).to.equal(usdt.target);
});

it('its erc721 address should be myNft', async function() {
  expect(await market.erc721()).to.equal(myNft.target);
});
it("account1 should have two nfts",async()=>{
expect(await myNft.balanceOf(account1.address)).to.equal(2);
});
it("account2 should have 10000 usdt",async()=>{
expect(await usdt.balanceOf(account2.address)).to.equal("100000000000000000000000000");
});


it('account2 should have 0 nfts', async function() {
  expect(await myNft.balanceOf(account2.address)).to.equal(0);
});

it('account1 can list two nfts to market', async function() {
  const price = "0x0000000000000000000000000000000000000000000000000001c6bf52634000";

})

it('account1 can unlist one nft from market', async function() {
  const price = "0x0000000000000000000000000000000000000000000000000001c6bf52634000";
  
})

it('account1 can change price of nft from market', async function() {
  
})

it('account2 can buy nft from market', async function() {
  
})
})