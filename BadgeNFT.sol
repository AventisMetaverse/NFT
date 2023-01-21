// contracts/BadgeNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract BadgeNFT is  ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private base_video =
        "ipfs://QmNT6kwrRsbuUpgbCkaxZR3a54TSdCdBC14rQZMNzzdbqF/";
    string private base_image = "ipfs://QmW6JeC28mbyUR8bV8QzkiG9xgp8zGFt8YmaQoDzh7CxNJ/";

    event NewWithdrawl(uint256 amount);


    constructor() ERC721("Badge NFT", "BNFT") {}

    function mint() public returns (uint256) {
        uint256 rarity = generateRarity();
        uint256 newItemId = _tokenIds.current();
        string memory tokenURI = createTokenURI(newItemId, rarity);
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }

    function generateRarity() internal view returns (uint256) {
        uint rand = uint(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        ) % 100;
        console.log("This is the random ", rand);
        if (rand <= 50) {
            return 1;
        } else if (rand <= 80) {
            return 2;
        } else if (rand <= 91) {
            return 3;
        } else if (rand <= 97) {
            return 4;
        } else {
            return 5;
        }
    }

    function createTokenURI(
        uint256 tokenId,
        uint256 rarity
    ) internal view returns (string memory) {
        string memory rarity_type = getRarityType(rarity);
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Aventis Badge NFT #',
            tokenId.toString(),
            '",',
            '"description": "Aventis Badge NFT",',
            '"image":"',
            string.concat(base_image, rarity.toString(), ".PNG"),
            '","animation_url": "',
            string.concat(base_video,rarity.toString(),".mp4"),
            '"',
            ',"attributes":[',
            "{",
            '"trait_type": "Type",',
            '"value":"',
            rarity_type,
            '"}'
            "]"
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function getRarityType(uint256 rarity) internal pure returns(string memory){
        string memory rarity_type = 'common';
        if(rarity == 2){
            rarity_type = 'uncommon';
        } else if(rarity == 3){
            rarity_type = 'rare';
        } else if(rarity == 4){
            rarity_type = 'epic';
        } else if(rarity == 5){
            rarity_type = 'legendary';
        }
        return rarity_type;
    }

    function contractURI() public pure returns (string memory) {
        return "ipfs://QmcwZMWxWnEc3kqGQXe3wBGXx3GPkh6Q4Qrj6oPSdSU8nb";
    }

    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _burn(tokenId);
    }

    function withdraw() public onlyOwner {
		uint256 amount = address(this).balance; // get the amount of ether in the contract
		require(amount > 0, 'You have no ether to withdraw');
        address owner = owner();
		(bool success, ) = owner.call{value: amount}('');
		require(success, 'Withdraw failed');
		emit NewWithdrawl(amount);
	}
}