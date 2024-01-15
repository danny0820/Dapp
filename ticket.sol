pragma solidity ^0.4.26;

contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function totalSupply() public view returns (uint256 total);
  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
 /* function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;*/
  function transferFrom(address _from, address _to, uint256 _tokenId) public ;
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract Ticketsystem is  ERC721,Ownable {

  using SafeMath for uint256;
    string public name_ = "TICKETNFT";
    uint256 public ticketPrice; // 票的价格
    uint256 public maxTickets;  // 票的最大数量
  struct ticket {
    uint32 userid;
    string username;
  }

  ticket[] public tickets;
  string public symbol_ = "Ticket";

  mapping (uint => address) public ticketToOwner;
  mapping (address => uint) ownerticketCount;
  mapping (uint => address) ticketApprovals; 

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _from, address indexed _to,uint indexed _tokenId);
  event Take(address _to, address _from,uint _tokenId);
  event Create(uint _tokenId, bytes32 userid,string username);

  function name() external view returns (string) {
        return name_;
  }

  function symbol() external view returns (string) {
        return symbol_;
  }

  function totalSupply() public view returns (uint256) {
    return tickets.length;
  }

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerticketCount[_owner]; // 此方法只是顯示某帳號 餘額
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return ticketToOwner[_tokenId]; // 此方法只是顯示某ticket 擁有者
  }


  function seeticketUserID(uint256 _tokenId) public view returns (uint32 userid) {
    return tickets[_tokenId].userid;
  }

  function seeticketUserName(uint256 _tokenId) public view returns (string username) {
    return tickets[_tokenId].username;
  }
  
  function getticketByOwner(address _owner) external view returns(uint[]) { //此方法回傳所有帳戶內的"tockenID"
    uint[] memory result = new uint[](ownerticketCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < tickets.length; i++) {
      if (ticketToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
  function transferFrom(address _from, address _to, uint256 _tokenId) public   {
        // 確保調用者有權轉移代幣
        require(ticketToOwner[_tokenId] == _from);
        require(_to != address(0));

        // 更新代币所有权
        ticketToOwner[_tokenId] = _to;

        // 更新代币计数
        ownerticketCount[_from] = ownerticketCount[_from].sub(1);
        ownerticketCount[_to] = ownerticketCount[_to].add(1);

        // 触发转移事件
        emit Transfer(_from, _to, _tokenId);
    }
    
  function transfer(address _to, uint256 _tokenId) public {
      
    //TO DO 請使用require判斷要轉的id是不是轉移者的
    require(ticketToOwner[_tokenId] == msg.sender );
    
    //增加受贈者的擁有數量
    ownerticketCount[_to] = ownerticketCount[_to].add(1);
    
    //減少轉出者的擁有數量
    ownerticketCount[msg.sender] = ownerticketCount[msg.sender].sub(1);
    
    //所有權轉移
    ticketToOwner[_tokenId] = _to;
    
    emit Transfer(msg.sender, _to, _tokenId);
  }


   function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        ticketToOwner[_tokenId] = _to;
        ownerticketCount[_to] = ownerticketCount[_to].add(1);
        emit Transfer(address(0), _to, _tokenId);
    }


    function createTicket(uint256 _ticketPrice, uint256 _maxTickets) public onlyOwner {
        ticketPrice = _ticketPrice *1 ether;
        maxTickets = _maxTickets;
        for (uint i = 0; i < _maxTickets; i++) {
            // 創建每一张票，初始時都歸合約擁有
            _mint(this, i);
            tickets.push(ticket({userid: uint32(0), username: "shop"})); //初始化票的結構
        }
    }
    function buyTicket(uint32 _userid, string _username, uint256 tokenId) public payable {
      require(tokenId < tickets.length, "Token ID is invalid");
      require(ticketToOwner[tokenId] == address(this), "Token is not available for sale");
      require(msg.value >= ticketPrice, "Insufficient funds to buy a ticket");

      // 转移Token代币的所有权
      transferFrom(address(this), msg.sender, tokenId);

      // 更新票的拥有者信息
      ownerticketCount[msg.sender] = ownerticketCount[msg.sender].add(1);
      tickets[tokenId] = ticket({userid: _userid, username: _username});
    }

  function getAvailableTokens() public view returns (uint256[] memory) {
          uint256 availableCount = 0;

          // 首先计算未售出 Token 的数量
          for (uint256 i = 0; i < tickets.length; i++) {
              if (ticketToOwner[i] == address(this)) {
                  availableCount++;
              }
          }

          // 根据计算出的数量创建数组，并填充未售出的 Token ID
          uint256[] memory availableTokens = new uint256[](availableCount);
          uint256 counter = 0;
          for (uint256 j = 0; j < tickets.length; j++) {
              if (ticketToOwner[j] == address(this)) {
                  availableTokens[counter] = j;
                  counter++;
              }
          }

          return availableTokens;
      }

   function returnTicket(uint256 _tokenId) public {
        // 確保調用者是當前的擁有者
        require(ticketToOwner[_tokenId] == msg.sender, "Caller is not the ticket owner");
        ticketToOwner[_tokenId] = address(this);
        tickets[_tokenId].userid = uint32(0);
        tickets[_tokenId].username = "shop";

        // 將票退還給合約
        ticketToOwner[_tokenId] = address(this);

        // 更新擁有者的票數
        ownerticketCount[msg.sender] = ownerticketCount[msg.sender].sub(1);
        ownerticketCount[address(this)] = ownerticketCount[address(this)].add(1);

        // 轉移
        emit Transfer(msg.sender, address(this), _tokenId);
        msg.sender.transfer(ticketPrice-1 ether);
    }
}
