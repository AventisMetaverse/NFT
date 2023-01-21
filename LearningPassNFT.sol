// contracts/LearningNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract LearningPassNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;
    IERC20 public USDC;
    ERC721Burnable public BADGE;

    struct Course {
        uint256 trainer_taught;
        uint256 self_paced;
    }

    mapping(uint256 => Course) public tokenIdToCourse;

    string public image_url =
        "ipfs://QmakiBoDwhQJSGEAdCVnWsrUxyKmyqjkA9HVHKf12w1iER";
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(address _token, address _badge) ERC721("Learning NFT", "LNFT") {
        USDC = IERC20(_token);
        BADGE = ERC721Burnable(_badge);
    }

    function mint() public {
        USDC.transferFrom(msg.sender, address(this), 500 ether);
        mintNew(msg.sender);
    }

    function mintNew(address minter) internal returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(minter, newItemId);
        _setTokenURI(newItemId, createTokenURI(newItemId, 1, 2));
        console.log(createTokenURI(newItemId, 1, 2));
        tokenIdToCourse[newItemId] = Course(1, 2);
        _tokenIds.increment();
        return newItemId;
    }

    function createTokenURI(
        uint256 tokenId,
        uint256 trainer,
        uint256 self
    ) internal view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Aventis Learning Pass NFT #',
            tokenId.toString(),
            '",',
            '"description": "Aventis Learning Pass NFT",',
            '"image": "',
            image_url,
            '"',
            ',"attributes":[',
            "{",
            '"display_type": "number",',
            '"trait_type": "Trainer Taught",',
            '"value":',
            trainer.toString(),
            '",max_value": 1'
            "},"
            "{",
            '"display_type": "number",',
            '"trait_type": "Self Paced",',
            '"value":',
            self.toString(),
            '",max_value":2'
            "}"
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

    function updateCourses(
        uint256 tokenId,
        uint256 trainer,
        uint256 self
    ) external onlyOwner returns (uint256) {
        Course memory courses = tokenIdToCourse[tokenId];
        require(
            trainer <= courses.trainer_taught || self <= courses.self_paced
        );
        tokenIdToCourse[tokenId] = Course(trainer, self);
        _setTokenURI(tokenId, createTokenURI(tokenId, trainer, self));
        console.log(tokenIdToCourse[tokenId].trainer_taught);
        return tokenId;
    }

    function exchangeBadgeForLearning(
        uint256[] calldata badgeIds
    ) public returns (uint256) {
        for (uint i = 0; i < 5; i++) {
            console.log(badgeIds[i]);
            BADGE.burn(badgeIds[i]);
        }
        uint256 tokenId = mintNew(msg.sender);
        return tokenId;
    }
}
