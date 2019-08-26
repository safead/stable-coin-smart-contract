pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./ERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20Burnable.sol";
import "./ERC20Detailed.sol";

contract EnfaceCurrency is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply = 0;

    constructor(uint256 initialSupply) public ERC20Detailed("Enface USDT", "EUSDT", 18) {  
        if (initialSupply > 0) _mint(msg.sender, initialSupply);
    }
 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address acc) public view returns (uint256) {
        return _balances[acc];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function mint(address acc, uint256 amount) public onlyOwner returns (bool) {
        _mint(acc, amount);
        return true;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address acc, uint256 amount) public {
        _burnFrom(acc, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address acc, uint256 amount) internal {
        require(acc != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[acc] = _balances[acc].add(amount);
        emit Transfer(address(0), acc, amount);
    }

    function _burn(address acc, uint256 amount) internal {
        require(acc != address(0), "ERC20: burn from the zero address");
        _balances[acc] = _balances[acc].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(acc, address(0), amount);
    }

    function _burnFrom(address acc, uint256 amount) internal {
        _approve(acc, _msgSender(), _allowances[acc][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
        _burn(acc, amount);
    }

}
