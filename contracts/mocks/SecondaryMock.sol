pragma solidity ^0.5.0;

import "../Secondary.sol";

contract SecondaryMock is Secondary {
    function onlyPrimaryMock() public view onlyPrimary {}
}
