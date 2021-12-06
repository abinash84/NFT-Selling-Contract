// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => address) private _artists;

    constructor() ERC721("MyNFT", "NFT") {}

    function mintNFT(address recipient, string memory tokenURI)
        public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _artists[newItemId]=recipient;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function artistOf(uint256 tokenId) public view virtual returns (address) { // Get the artist of a particular token
        address artist = _artists[tokenId];
        require(artist != address(0), "ERC721: owner query for nonexistent token");
        return artist;
    }
}



contract SellNFT{
    

    MyNFT public nftAddress;
    uint256 public price;
    address owner;
    uint256 public tokenId; // Token of the NFT  whih is to be sold
    uint256 public perc = 10; // percentage of royalty
    event Sent(address indexed payee, uint256 amount);

    /**
    *  Contract Constructor
    * @param _nftAddress address for Crypto Arte non-fungible token contract 
    * @param _currentPrice initial sales price
    */
    constructor(address _nftAddress, uint256 _currentPrice,uint256 _tokenId) { 
        require(_nftAddress != address(0) && _nftAddress != address(this));
        require(_currentPrice > 0);
        nftAddress = MyNFT(_nftAddress);
        price = _currentPrice;
        tokenId = _tokenId;
        owner=msg.sender;
    }
     
    modifier onlyOwner{       // Access control
        require(msg.sender==owner);
        _;
    }
   

    
    function BuyToken() public payable  {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= (price + (perc*price)/100)*1e18);
        address tokenSeller = nftAddress.ownerOf(tokenId);
        address artist = nftAddress.artistOf(tokenId);
        nftAddress.safeTransferFrom(tokenSeller, msg.sender, tokenId);
        uint256 cost = (msg.value*100)/(100+perc);  //Calculating cost price
        uint256 royalty = msg.value - cost;  // Calculating royalty
        payable(tokenSeller).transfer(cost);
        payable(artist).transfer(royalty);
        emit Sent(tokenSeller,cost);
        emit Sent(artist,royalty);
    }


    
    function updatePrice(uint256 _currentPrice) public onlyOwner {
        require(_currentPrice > 0);
        price = _currentPrice;
    }        

}