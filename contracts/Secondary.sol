pragma solidity ^0.5.0;

import "./Context.sol";

contract Secondary is Context {

    address private _primary;
    event PrimaryTransferred(address recipient);

    constructor () internal {
        _primary = _msgSender();
        emit PrimaryTransferred(_primary);
    }

    modifier onlyPrimary() {
        require(_msgSender() == _primary, "Secondary: caller is not the primary account");
        _;
    }

    function primary() public view returns (address) {
        return _primary;
    }

    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(_primary);
    }
}
