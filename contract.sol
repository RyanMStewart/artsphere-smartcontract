// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtGallery is ERC721Enumerable, Ownable {
    struct ArtItem {
        string name;
        string description;
        string uri; // URI to the 3D art object
    }

    ArtItem[] public artItems;

    constructor() ERC721("ArtGallery", "ART") {}

    function createArtItem(string memory name, string memory description, string memory uri) external onlyOwner {
        ArtItem memory newItem = ArtItem(name, description, uri);
        artItems.push(newItem);
        uint256 newArtItemId = artItems.length - 1;
        _mint(msg.sender, newArtItemId);
        _setTokenURI(newArtItemId, uri);
    }

    function getArtItem(uint256 tokenId) external view returns (string memory name, string memory description, string memory uri) {
        require(_exists(tokenId), "Art item does not exist");
        ArtItem memory artItem = artItems[tokenId];
        return (artItem.name, artItem.description, artItem.uri);
    }

    function purchaseArtItem(uint256 tokenId) external payable {
        require(msg.value >= 0.1 ether, "Minimum purchase price is 0.1 ether");
        require(_exists(tokenId), "Art item does not exist");
        address owner = ownerOf(tokenId);
        payable(owner).transfer(msg.value);
        _transfer(owner, msg.sender, tokenId);
    }
}
