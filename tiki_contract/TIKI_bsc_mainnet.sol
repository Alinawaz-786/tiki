// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256);
} library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
} interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
} interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender,uint amount0In,uint amount1In,uint amount0Out,uint amount1Out,address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
} library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }
    function get(Map storage map, address key) internal view returns (uint) {
        return map.values[key];
    }
    function getIndexOfKey(Map storage map, address key) internal view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }
    function getKeyAtIndex(Map storage map, uint index) internal view returns (address) {
        return map.keys[index];
    }
    function size(Map storage map) internal view returns (uint) {
        return map.keys.length;
    }
    function set(Map storage map, address key, uint val) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }
    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.values[key];
        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
} abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
} interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
} contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
} interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256);
    function distributeDividends() external payable;
    function withdrawDividend() external;
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
} contract DividendPayingToken is ERC20, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;
  uint256 constant internal magnitude = 2**128;
  uint256 internal magnifiedDividendPerShare;
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;
  uint256 public totalDividendsDistributed;
  constructor(string memory _name, string memory _symbol) public ERC20(_name, _symbol) {}
  receive() external payable {
    distributeDividends();
  }
  function distributeDividends() public override payable {
    require(totalSupply() > 0);
    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);
      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }
  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }
  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
      emit DividendWithdrawn(user, _withdrawableDividend);
      (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
      if(!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
        return 0;
      }
      return _withdrawableDividend;
    }
    return 0;
  }
  function dividendOf(address _owner) public view override returns(uint256) {
    return withdrawableDividendOf(_owner);
  }
  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }
  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    return withdrawnDividends[_owner];
  }
  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);
    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
  }
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
  }
  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
} library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
} abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() {
        _paused = false;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
} interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
} interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
} contract Whitelist is Ownable {

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

contract TIKI is ERC20, Whitelist {
    using SafeMath for uint256;
    bool private swapping;
    uint8 constant MAX_REFER_DEPTH = 2;
    uint256 public maxSellTransactionAmount = 1000000 * (10**18);
    uint256 public swapTokensAtAmount = 200000 * (10**18);
    uint256 public immutable BNBRewardsFee;
    uint256 public immutable liquidityFee;
    uint256 public immutable totalFees;
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable bounceFixedSaleWallet;
    TIKIDividendTracker public dividendTracker;
    address public liquidityWallet;
    address public mainWallet;
    struct Account {
        address payable referrer;
    }
    mapping(address => Account) public accounts;
    struct Fee {
        uint256 bnbFee;
        uint256 lPoolFee;
        uint256 redistributionFee;
        uint256 walletFee;
    }
    enum userType {
        WhiteListedSell,
        NormalSell,
        WhiteListedBuys,
        WhitelistedBuysRef,
        NormalBuys
    }
    enum Type {
        BUY,
        REF_BUY,
        SELL
    }
    enum Upline {
        ONE,
        TWO
    }
    mapping(userType => Fee) public feeMapping;
    uint256 public immutable sellFeeIncreaseFactor = 120;
    uint256 public gasForProcessing = 300000;
    uint256 public immutable fixedSaleStartTimestamp = 1623960000; //June 17, 20:00 UTC, 2021
    uint256 public immutable fixedSaleEarlyParticipantDuration = 600;
    uint256 public immutable fixedSaleEarlyParticipantBuysThreshold = 600;
    uint256 public numberOfFixedSaleBuys;
    mapping(address => bool) public fixedSaleBuyers;
    uint256 public immutable tradingEnabledTimestamp = 1623967200; //June 17, 22:00 UTC, 2021

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private canTransferBeforeTradingIsEnabled;
    mapping(address => bool) public firstTx;
    mapping(address => bool) public fixedSaleEarlyParticipants;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event FixedSaleEarlyParticipantsAdded(address[] participants);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet,address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue,uint256 indexed oldValue);
    event FixedSaleBuy(address indexed account,uint256 indexed amount,bool indexed earlyParticipant,uint256 numberOfBuyers);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 iterations,uint256 claims,uint256 lastProcessedIndex,bool indexed automatic,uint256 gas,address indexed processor);
    event RegisteredReferer(address referee, address referrer);
    event UpdatedUserLastActiveTime(address user, uint256 timestamp);
    event PaidReferral(address from, address to, uint256 amount, uint256 level);

    constructor() public ERC20("TIKI", "TIKI") {
        intializeFee();
        uint256 _BNBRewardsFee = 10;
        uint256 _liquidityFee = 5;
        BNBRewardsFee = _BNBRewardsFee;
        liquidityFee = _liquidityFee;
        totalFees = _BNBRewardsFee.add(_liquidityFee);
        dividendTracker = new TIKIDividendTracker();
        liquidityWallet = owner();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        address _bounceFixedSaleWallet = 0x4Fc4bFeDc5c82644514fACF716C7F888a0C73cCc;
        bounceFixedSaleWallet = _bounceFixedSaleWallet;
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(address(_bounceFixedSaleWallet));
        excludeFromFees(liquidityWallet, true);
        excludeFromFees(address(this), true);
        canTransferBeforeTradingIsEnabled[owner()] = true;
        canTransferBeforeTradingIsEnabled[_bounceFixedSaleWallet] = true;
        _mint(owner(), 1000000000 * (10**18));
        _mint(address(this), 1000000000  * (10**18));
    }
    receive() external payable {}
    function hasReferrer(address addr) public view returns (bool) {
        return accounts[addr].referrer != address(0);
    }
    function isCircularReference(address referrer, address referee)
        internal
        view
        returns (bool)
    {
        address parent = referrer;
        for (uint256 i; i < MAX_REFER_DEPTH; i++) {
            if (parent == address(0)) {
                break;
            }
            if (parent == referee) {
                return true;
            }
            parent = accounts[parent].referrer;
        }
        return false;
    }

    function payReferral(
        Upline level,
        uint256 bnbAmount,
        uint256 bnbAmountRef,
        uint256 lpAmount,
        uint256 distributionAmount,
        uint256 walletAmount
    ) internal {
        Account memory userAccount = accounts[msg.sender];
        address payable parent = userAccount.referrer;
        if (level == Upline.ONE) {
            uint256 current = address(this).balance;
            swapTokensForEth(bnbAmount);
            uint256 newBalance = address(this).balance;
            parent.transfer(newBalance.sub(current));
            swapAndLiquify(lpAmount);
            swapAndSendDividends(distributionAmount);
            super._transfer(msg.sender, mainWallet, walletAmount);
        } else if (level == Upline.TWO) {
            Account storage parentAccount = accounts[userAccount.referrer];
            address payable parentOfparent = parentAccount.referrer;
            uint256 current = address(this).balance;
            swapTokensForEth(bnbAmount);
            uint256 newBalance = address(this).balance;
            parent.transfer(newBalance.sub(current));
            current = address(this).balance;
            swapTokensForEth(bnbAmountRef);
            newBalance = address(this).balance;
            parentOfparent.transfer(newBalance.sub(current));
            swapAndLiquify(lpAmount);
            swapAndSendDividends(distributionAmount);
            super._transfer(msg.sender, mainWallet, walletAmount);
        }
        swapAndLiquify(lpAmount);
        swapAndSendDividends(distributionAmount);
        super._transfer(msg.sender, mainWallet, walletAmount);
    }

    function userTypeFee(userType _type)
        internal
        view
        returns (
            uint256 bnbFee,
            uint256 lpFee,
            uint256 distributionFee,
            uint256 walletFee
        )
    {
        return (
            feeMapping[_type].bnbFee,
            feeMapping[_type].lPoolFee,
            feeMapping[_type].redistributionFee,
            feeMapping[_type].walletFee
        );
    }

    function processBuyTax(uint256 amount)
        internal
        returns (uint256 remain_amount)
    {
        address payable parent = accounts[msg.sender].referrer;
        address payable parentOfparent = accounts[parent].referrer;
        uint256 bnbAmount;
        uint256 none;
        uint256 lpAmount;
        uint256 distributionAmount;
        uint256 walletAmount;
        (
            bnbAmount,
            none,
            lpAmount,
            distributionAmount,
            walletAmount
        ) = (parent != address(0) &&
            !firstTx[msg.sender] &&
            parentOfparent == address(0))
            ? calculateFee(Type.BUY, whitelisted(msg.sender), amount)
            : (parent != address(0) &&
                !firstTx[msg.sender] &&
                parentOfparent != address(0))
            ? calculateFee(Type.REF_BUY, whitelisted(msg.sender), amount)
            : calculateFee(Type.BUY, whitelisted(msg.sender), amount);

        (parent != address(0) &&
            !firstTx[msg.sender] &&
            parentOfparent == address(0))
            ? payReferral(
                Upline.ONE,
                bnbAmount,
                none,
                lpAmount,
                distributionAmount,
                walletAmount
            )
            : (parent != address(0) &&
                !firstTx[msg.sender] &&
                parentOfparent != address(0))
            ? payReferral(
                Upline.TWO,
                bnbAmount,
                none,
                lpAmount,
                distributionAmount,
                walletAmount
            )
            : processTax(
                bnbAmount,
                none,
                lpAmount,
                distributionAmount,
                walletAmount
            );
        firstTx[msg.sender] = true;
        remain_amount =
            amount -
            (bnbAmount + none + lpAmount + distributionAmount + walletAmount);
        return remain_amount;
    }

    function processSellTax(uint256 amount)
        internal
        returns (uint256 remain_amount)
    {
        uint256 bnbAmount;
        uint256 none;
        uint256 lpAmount;
        uint256 distributionAmount;
        uint256 walletAmount;
        (
            bnbAmount,
            none,
            lpAmount,
            distributionAmount,
            walletAmount
        ) = calculateFee(Type.SELL, whitelisted(msg.sender), amount);
        processTax(bnbAmount, none, lpAmount, distributionAmount, walletAmount);
        remain_amount =
            amount -
            (bnbAmount + none + lpAmount + distributionAmount + walletAmount);
        return remain_amount;
    }

    function calculateFee(
        Type trade,
        bool isWhitelisted,
        uint256 amount
    )
        internal
        view
        returns (
            uint256 bnbAmount,
            uint256 bnbAmountRef,
            uint256 lpAmount,
            uint256 distributionAmount,
            uint256 walletAmount
        )
    {
        uint256 bnbFee;
        uint256 lpFee;
        uint256 distributionFee;
        uint256 walletFee;
        if (!isWhitelisted && trade == Type.BUY) {
            (bnbFee, lpFee, distributionFee, walletFee) = userTypeFee(
                userType.NormalBuys
            );
        }
        if (isWhitelisted && trade == Type.BUY) {
            (bnbFee, lpFee, distributionFee, walletFee) = userTypeFee(
                userType.WhiteListedBuys
            );
        }
        if (isWhitelisted && trade == Type.SELL) {
            (bnbFee, lpFee, distributionFee, walletFee) = userTypeFee(
                userType.WhiteListedSell
            );
        }
        if (!isWhitelisted && trade == Type.SELL) {
            (bnbFee, lpFee, distributionFee, walletFee) = userTypeFee(
                userType.NormalSell
            );
        }
        if (isWhitelisted && trade == Type.REF_BUY) {
            (bnbFee, lpFee, distributionFee, walletFee) = userTypeFee(
                userType.WhitelistedBuysRef
            );
        }
        return (
            (isWhitelisted && trade == Type.REF_BUY)
                ? ((bnbFee - 2) * amount) / 100
                : (bnbFee * amount) / 100,
            (isWhitelisted && trade == Type.REF_BUY)
                ? ((bnbFee - 10) * amount) / 100
                : 0,
            lpFee.mul(amount).div(100),
            (distributionFee * amount) / 100,
            (walletFee * amount) / 100
        );
    }
    function processTax(
        uint256 bnbAmount,
        uint256 none,
        uint256 lpAmount,
        uint256 distributionAmount,
        uint256 walletAmount
    ) internal {
        swapAndSendDividends(bnbAmount); //swap tokens with BNB and depoist all the smart contract balance to the dividenerTracker
        swapAndLiquify(lpAmount); // returns lp tokens to the liquidity wallet
        swapAndSendDividends(distributionAmount); // swap tokens with BNB and depoist all the smart contract balance to the dividenerTracker
        super._transfer(msg.sender, mainWallet, walletAmount); // transfer n% to the main wallet
    }
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != address(dividendTracker),
            "TIKI: The dividend tracker already has that address"
        );
        TIKIDividendTracker newDividendTracker = TIKIDividendTracker(
            payable(newAddress)
        );
        require(
            newDividendTracker.owner() == address(this),
            "TIKI: The new dividend tracker must be owned by the TIKI token contract"
        );
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "TIKI: The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "TIKI: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    function addFixedSaleEarlyParticipants(address[] calldata accounts)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            fixedSaleEarlyParticipants[accounts[i]] = true;
        }

        emit FixedSaleEarlyParticipantsAdded(accounts);
    }
    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "TIKI: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }
    function addReferrer(address payable referrer) external onlyOwner {
        require(referrer != address(0), "Referrer cannot be 0x0 address");
        require(
            !isCircularReference(referrer, msg.sender),
            "Referee cannot be one of referrer uplines"
        );
        require(
            accounts[msg.sender].referrer == address(0),
            "Address have been registered upline"
        );
        Account storage userAccount = accounts[msg.sender];
        userAccount.referrer = referrer;
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "TIKI: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateLiquidityWallet(address newLiquidityWallet)
        public
        onlyOwner
    {
        require(
            newLiquidityWallet != liquidityWallet,
            "TIKI: The liquidity wallet is already this address"
        );
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200000 && newValue <= 500000,
            "TIKI: gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "TIKI: Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        mainWallet = to;
        bool tradingIsEnabled = getTradingIsEnabled();
        if (!tradingIsEnabled) {
            require(
                canTransferBeforeTradingIsEnabled[from],
                "TIKI: This account cannot send tokens until trading is enabled"
            );
        }
        {
            if (amount == 0) {
                super._transfer(from, to, 0);
                return;
            }
        }

        bool isFixedSaleBuy = from == bounceFixedSaleWallet && to != owner(); // true
        if (isFixedSaleBuy) {
            //
            require(
                block.timestamp >= fixedSaleStartTimestamp,
                "TIKI: The fixed-sale has not started yet."
            ); //

            {
                bool openToEveryone = block.timestamp.sub(
                    fixedSaleStartTimestamp
                ) >=
                    fixedSaleEarlyParticipantDuration ||
                    numberOfFixedSaleBuys >=
                    fixedSaleEarlyParticipantBuysThreshold;

                if (!openToEveryone) {
                    require(
                        fixedSaleEarlyParticipants[to],
                        "TIKI: The fixed-sale is only available to certain participants at the start"
                    );
                }
            }
            if (!fixedSaleBuyers[to]) {
                fixedSaleBuyers[to] = true;
                numberOfFixedSaleBuys = numberOfFixedSaleBuys.add(1);
            }
            // buy logic
            amount = processBuyTax(amount);

            emit FixedSaleBuy(
                to,
                amount,
                fixedSaleEarlyParticipants[to],
                numberOfFixedSaleBuys
            );
        }

        if (
            !swapping && //  false
            tradingIsEnabled && // false
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
            from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            msg.sender != address(uniswapV2Router) &&
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(
                amount <= maxSellTransactionAmount,
                "Sell transfer amount exceeds the maxSellTransactionAmount."
            );
            amount = processSellTax(amount);
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount; // false

        if (
            tradingIsEnabled &&
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != liquidityWallet &&
            to != liquidityWallet &&
            msg.sender != address(uniswapV2Router)
        ) {
            swapping = true;
            uint256 swapTokens = balanceOf(address(this)).mul(liquidityFee).div(
                totalFees
            );
            swapAndLiquify(swapTokens);
            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);
            swapping = false;
        }

        bool takeFee = !isFixedSaleBuy && tradingIsEnabled && !swapping; // false
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            if (automatedMarketMakerPairs[to]) {
                fees = fees.mul(sellFeeIncreaseFactor).div(100);
            }
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }
        super._transfer(from, to, amount);
        try
            dividendTracker.setBalance(payable(from), balanceOf(from))
        {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    function intializeFee() internal {
        feeMapping[userType.NormalBuys].bnbFee = 10;
        feeMapping[userType.NormalBuys].lPoolFee = 2;
        feeMapping[userType.NormalBuys].redistributionFee = 2;
        feeMapping[userType.NormalBuys].walletFee = 1;
        feeMapping[userType.WhiteListedBuys].bnbFee = 10; // (userA)
        feeMapping[userType.WhiteListedBuys].lPoolFee = 2;
        feeMapping[userType.WhiteListedBuys].redistributionFee = 2;
        feeMapping[userType.WhiteListedBuys].walletFee = 1;
        feeMapping[userType.WhitelistedBuysRef].bnbFee = 12; // (userA) + (userB)
        feeMapping[userType.WhitelistedBuysRef].lPoolFee = 1;
        feeMapping[userType.WhitelistedBuysRef].redistributionFee = 1;
        feeMapping[userType.WhitelistedBuysRef].walletFee = 1;
        feeMapping[userType.NormalSell].bnbFee = 10;
        feeMapping[userType.NormalSell].lPoolFee = 4;
        feeMapping[userType.NormalSell].redistributionFee = 4;
        feeMapping[userType.NormalSell].walletFee = 2;
        feeMapping[userType.WhiteListedSell].bnbFee = 5;
        feeMapping[userType.WhiteListedSell].lPoolFee = 2;
        feeMapping[userType.WhiteListedSell].redistributionFee = 2;
        feeMapping[userType.WhiteListedSell].walletFee = 1;
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance in`to halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half); 
        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            //            block.timestamp
            block.timestamp + 300
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }
    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForEth(tokens);
        uint256 dividends = address(this).balance;
        (bool success, ) = address(dividendTracker).call{value: dividends}("");

        if (success) {
            emit SendDividends(tokens, dividends);
        }
    }
}

contract TIKIDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;
    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor()
        public
        DividendPayingToken("TIKI_Dividend_Tracker", "TIKI_Dividend_Tracker")
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 10000 * (10**18); //must hold 10000+ tokens
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal override {
        require(false, "TIKI_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(
            false,
            "TIKI_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main TIKI contract."
        );
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "TIKI_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "TIKI_Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000,-1,-1,0,0,0,0,0);
        }
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
        processAccount(account, true);
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }
    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account);
        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }
}