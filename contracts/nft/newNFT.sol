// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract newNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 public newItemId;
    struct axieInfinity {
        uint256 tokenId;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }
    // map cryptoboy's token id to crypto boy
    mapping(uint256 => axieInfinity) public allaxieInfinityToBuys;
    // check if token URI exists
    mapping(string => bool) public tokenURIExists;

    constructor() ERC721("Axie Infinity NFT", "AIN") {}

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    /*function _baseURI() internal pure override returns (string memory) {
            return "https://nexus.arhamsoft.info/";
     }*/

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function createNewNFT(address wallet_address, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        // check if a token exists with the above token id => incremented counter
        require(!_exists(newItemId));
        // check if the token URI already exists or not
        require(!tokenURIExists[tokenURI]);

        // mint the token
        _mint(wallet_address, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // make passed token URI as exists
        tokenURIExists[tokenURI] = true;

        // creat a new crypto boy (struct) and pass in new values
        axieInfinity memory newAxieInfinity = axieInfinity(
            newItemId,
            tokenURI,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            0,
            0,
            true
        );
        // add the token id and it's crypto boy to all crypto boys mapping

        allaxieInfinityToBuys[newItemId] = newAxieInfinity;

        return newItemId;
    }

    // by a token by passing in the token's id
    function buyToken(uint256 _tokenId) public payable {
        // check if the function caller is not an zero account address
        require(msg.sender != address(0));
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0));
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner != msg.sender);
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => axieInfinity)
        axieInfinity memory axieInfinitytobuy = allaxieInfinityToBuys[_tokenId];
        // price sent in to buy should be equal to or more than the token's price
        require(msg.value >= axieInfinitytobuy.price);
        // token should be for sale
        require(axieInfinitytobuy.forSale);
        // transfer the token from owner to the caller of the function (buyer)
        _transfer(tokenOwner, msg.sender, _tokenId);
        // get owner of the token
        address payable sendTo = axieInfinitytobuy.currentOwner;
        // send token's worth of ethers to the owner
        sendTo.transfer(msg.value);
        // update the token's previous owner
        axieInfinitytobuy.previousOwner = axieInfinitytobuy.currentOwner;
        // update the token's current owner
        axieInfinitytobuy.currentOwner = payable(msg.sender);
        // update the how many times this token was transfered
        axieInfinitytobuy.numberOfTransfers += 1;
        // set and update that token in the mapping
        allaxieInfinityToBuys[_tokenId] = axieInfinitytobuy;
    }

    // get owner of the token
    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    // get metadata of the token
    function getTokenMetaData(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    // get total number of tokens minted so far
    /*function getNumberOfTokensMinted() public view returns(uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }*/
    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        axieInfinity memory axieInfinityToBoy = allaxieInfinityToBuys[_tokenId];
        // update token's price with new price
        axieInfinityToBoy.price = _newPrice;
        // set and update that token in the mapping
        allaxieInfinityToBuys[_tokenId] = axieInfinityToBoy;
    }

    // switch between set for sale and set not for sale
    function toggleForSale(uint256 _tokenId) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        axieInfinity memory axieInfinitytoboy = allaxieInfinityToBuys[_tokenId];
        // if token's forSale is false make it true and vice versa
        if (axieInfinitytoboy.forSale) {
            axieInfinitytoboy.forSale = false;
        } else {
            axieInfinitytoboy.forSale = true;
        }
        // set and update that token in the mapping
        allaxieInfinityToBuys[_tokenId] = axieInfinitytoboy;
    }

    function sellToken( string memory tokenURI) public payable {
        uint256  _price = 0;
        // require caller of the function is not an empty address
        require(msg.sender != address(0));

        require(!isExist(_price));

        transferFrom(msg.sender, address(0) ,_tokenid);
        // creat a new crypto boy (struct) and pass in new values
        axieInfinity memory newAxieInfinity = axieInfinity(
            0,
            tokenURI,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            0,
            0,
            true
        );
        // mapping the address into the specify Index.
        allaxieInfinityToBuys[0] = newAxieInfinity;
    }
        /*
        *   Now I am starting working on bidding
        */

    /*
        Chile is a long, narrow country stretching along South America's
        western edge, with more than 6,000km of Pacific Ocean coastline.
        Santiago, its capital, sits in a valley surrounded by the Andes
        and Chilean Coast Range mountains. The city's palm-lined Plaza
        de Armas contains the neoclassical cathedral and the National
        History Museum. The massive Parque Metropolitano offers swimming
    */
}
