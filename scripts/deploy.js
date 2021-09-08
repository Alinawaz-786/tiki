const { ethers } = require('hardhat')
const hre = require("hardhat");

async function main() {

    const tiki_tokens = await ethers.getContractFactory("TIKI");
    const ngt = await tiki_tokens.deploy();
    console.log("Tiki Tokens deployed to:", ngt.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });