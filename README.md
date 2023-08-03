# artsphere-smartcontract
Solidity Smart Contract for ArtSphere Project

Here's an explanation of the contract:

It's using OpenZeppelin's ERC721 contract to provide a basis for the NFT functionality.
ArtItem struct is used to define each art piece, which contains name, description, and URI to the 3D object.
createArtItem is a function that only the contract owner can call to create new art items.
getArtItem allows anyone to get details about an art item, given its token ID.
purchaseArtItem allows anyone to purchase an art item, given its token ID, and the minimum purchase price is 0.1 ether.
