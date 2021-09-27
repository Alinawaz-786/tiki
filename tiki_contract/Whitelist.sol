pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Whitelist is Ownable {

    mapping (address => bool) private whitelistedMap;

    event Whitelisted(address indexed account, bool isWhitelisted);

    function whitelisted(address _address)
    public
    view
    returns (bool)
    {
        return whitelistedMap[_address];
    }

    function addAddress(address _address)
    public
    onlyOwner
    {
        require(whitelistedMap[_address] != true);
        whitelistedMap[_address] = true;
        emit Whitelisted(_address, true);
    }

    function removeAddress(address _address)
    public
    onlyOwner
    {
        require(whitelistedMap[_address] != false);
        whitelistedMap[_address] = false;
        emit Whitelisted(_address, false);
    }
}