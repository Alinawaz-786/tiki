const { ethers } = require('hardhat')
const hre = require("hardhat");

async function main() {


    const Pizza = await hre.ethers.getContractFactory("GLDToken");
    const greeter = await Pizza.deploy();
    console.log("Pizza deployed to:", greeter.address);

    // const tiki_tokens = await ethers.getContractFactory("SousChef");
    // // const ngt = await tiki_tokens.deploy();
    // const ngt = await tiki_tokens.deploy("0x050b5E53d1449B711c6f48aAD213C3bf56C597D9","100000000000000000",10951000,10991000);
    // console.log("Tiki Tokens deployed to:", ngt.address);


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