// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Market{
    IERC20 public erc20;
    IERC721 public erc721;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED=0x150b7a02;
    struct Order{
        address seller;
        uint256 tokenId;
        uint256 price;
    }
    mapping (uint256=>Order) public orderOfId;
    Order[] public orders;
    mapping (uint256=>uint256) public idToOrderIndex;
    event Deal(address seller,address buyer,uint256 tokenId,uint256 price);
   event NewOrder(address seller,uint256 tokenId,uint256 price);
   event PriceChanged(address seller,uint256 tokenId,uint256 previousPrice,uint256 price);
   event OrderCancelled(address seller,uint256 tokenId);
    constructor(address _erc20, address _erc721){
        require(_erc20!=address(0),"zero address");
        require(_erc721!=address(0),"zero address");
        erc20=IERC20(_erc20);
        erc721=IERC721(_erc721);

    }
    function buy(uint256 _tokenId) external {
        address seller=orderOfId[_tokenId].seller;
        address buyer=msg.sender;
        uint256 price=orderOfId[_tokenId].price;
        require(erc20.transferFrom(buyer, seller, price),"trf not succ");
        erc721.safeTransferFrom(address(this), buyer, _tokenId);
         removeOrder(_tokenId);
        emit Deal(seller,buyer,_tokenId,price);


    }
    function cancelOrder(uint256 _tokenId) external {
        address seller=orderOfId[_tokenId].seller;
        require(msg.sender==seller,"not seller");
        erc721.safeTransferFrom(address(this), seller, _tokenId);
        removeOrder(_tokenId);
        emit OrderCancelled(seller, _tokenId);
    }
    function changePrice(uint256 _tokenId,uint256 _price) external {
        address seller=orderOfId[_tokenId].seller;
        require(msg.sender==seller,"not seller");
        uint256 previousPrice=orderOfId[_tokenId].price;
        orderOfId[_tokenId].price=_price;
        Order storage order=orders[idToOrderIndex[_tokenId]];
        order.price=_price;
       
        emit PriceChanged(seller, _tokenId, previousPrice, _price);


    }
    function onERC721Received (address oprator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4){
        uint256 price=toUint256(data,0);
        require(price>0,"price must be >0");
        orders.push(Order(from,tokenId,price));
        orderOfId[tokenId]=Order(from,tokenId,price);
        idToOrderIndex[tokenId]=orders.length-1;
        emit NewOrder(from, tokenId, price);
            return MAGIC_ON_ERC721_RECEIVED;
         }
    
    function toUint256(bytes memory _bytes,uint256 _start) public pure returns (uint256){
        require(_start+32>=_start,"market:toUint256_overflow");
        uint256 tempUint;
        assembly{
            tempUint:=mload(add(add(_bytes,0x20),_start))
        }
        return tempUint;
    }
    
    function removeOrder(uint256 _tokenId) internal {
        uint256 index=idToOrderIndex[_tokenId];
        uint256 lastIndex=orders.length-1;
        if(index!=lastIndex){
            Order storage lastOrder=orders[lastIndex];
            orders[index]=lastOrder;
            idToOrderIndex[lastOrder.tokenId]=index;
        }
        orders.pop();
        delete orderOfId[_tokenId];
        delete idToOrderIndex[_tokenId];

    }
    function getOrderLength() external view returns (uint256){
        return orders.length;
    }
    function getAllNFTs() external view returns (Order[] memory){
        return orders;
    }
    function getMyNFTs() external view returns (Order[] memory){
        Order[] memory myOrders=new Order[](orders.length);
        uint256 count=0;
        for(uint256 i=0;i<orders.length;i++){
          if (orders[i].seller==msg.sender){
            myOrders[count]=orders[i];
            count++;
          }
        }
        return myOrders;
    }
    function isListed(uint256 _tokenId) public view returns (bool){
        return orderOfId[_tokenId].seller!=address(0);
    }
   

}