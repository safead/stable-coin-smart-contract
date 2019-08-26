pragma solidity ^0.5.0;

import "../MinterRole.sol";

contract MinterRoleMock is MinterRole {
    function removeMinter(address account) public {
        _removeMinter(account);
    }

    function onlyMinterMock() public view onlyMinter {}

    function _removeMinter(address account) internal {
        super._removeMinter(account);
    }
}
