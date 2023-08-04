// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ArtGallery is ERC721Enumerable, Ownable, Pausable {
    struct ArtItem {
        string name;
        string description;
        uint256 price;
        uint8 royaltyPercentage;
        uint8 resaleCommission; // Percentage of commission on resale
        bool forSale;
        uint256 auctionEndTime;
    }

    ArtItem[] public artItems;

    mapping (uint256 => address payable) private _artist;

    event ArtCreated(address artist, uint256 tokenId);
    event Purchase(address buyer, uint256 tokenId, uint256 price);
    event AuctionStarted(uint256 tokenId, uint256 endTime);

    modifier onlyArtist(uint256 tokenId) {
        require(msg.sender == _artist[tokenId], "You are not the artist");
        _;
    }

    constructor() ERC721("ArtGallery", "ART") {}

    function createArtItem(string memory name, string memory description, uint256 price, uint8 royaltyPercentage) external whenNotPaused {
        ArtItem memory newItem = ArtItem(name, description, price, royaltyPercentage, true);
        artItems.push(newItem);
        uint256 newArtItemId = artItems.length - 1;
        _mint(msg.sender, newArtItemId);
        _artist[newArtItemId] = payable(msg.sender);
        emit ArtCreated(msg.sender, newArtItemId);
    }

    function updateArtItem(uint256 tokenId, uint256 price, uint8 royaltyPercentage, bool forSale) external onlyArtist(tokenId) {
        require(_exists(tokenId), "Art item does not exist");
        ArtItem storage artItem = artItems[tokenId];
        artItem.price = price;
        artItem.royaltyPercentage = royaltyPercentage;
        artItem.forSale = forSale;
    }

    function getArtItem(uint256 tokenId) external view returns (string memory name, string memory description, uint256 price, uint8 royaltyPercentage, bool forSale) {
        require(_exists(tokenId), "Art item does not exist");
        ArtItem memory artItem = artItems[tokenId];
        return (artItem.name, artItem.description, artItem.price, artItem.royaltyPercentage, artItem.forSale);
    }

    function startAuction(uint256 tokenId, uint256 duration) external onlyArtist(tokenId) {
        ArtItem storage artItem = artItems[tokenId];
        artItem.auctionEndTime = block.timestamp + duration;
        emit AuctionStarted(tokenId, artItem.auctionEndTime);
    }

    function purchaseArtItem(uint256 tokenId) external payable whenNotPaused {
        require(_exists(tokenId), "Art item does not exist");
        ArtItem storage artItem = artItems[tokenId];
        require(artItem.forSale, "Art item is not for sale");
        require(msg.value >= artItem.price, "Insufficient funds sent");
        require(artItem.auctionEndTime == 0 || block.timestamp < artItem.auctionEndTime, "Auction ended");

        address payable artist = _artist[tokenId];
        address payable previousOwner = payable(ownerOf(tokenId));

        uint256 royaltyValue = (msg.value * artItem.royaltyPercentage) / 100;
        uint256 commissionValue = (msg.value * artItem.resaleCommission) / 100;

        artist.transfer(royaltyValue);
        previousOwner.transfer(msg.value - royaltyValue - commissionValue);
        payable(owner()).transfer(commissionValue); // Resale commission to the contract owner

        _transfer(previousOwner, msg.sender, tokenId);

        emit Purchase(msg.sender, tokenId, msg.value);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
