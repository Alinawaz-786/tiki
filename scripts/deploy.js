const { ethers } = require('hardhat')
const hre = require("hardhat");

async function main() {

    const tiki_tokens = await ethers.getContractFactory("TIKI");
    const ngt = await tiki_tokens.deploy();
    console.log("Tiki Tokens deployed to:", ngt.address);


/*    const Greeter = await hre.ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, Hardhat!");
    await greeter.deployed();
    console.log("Greeter deployed to:", greeter.address);*/
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });