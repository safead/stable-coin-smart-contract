pragma solidity ^0.5.6;

contract EnfaceMain {

    address owner;
    uint256 commissionAlias;
    uint256 commissionRecordHashed;
    uint256 commissionRecord;

    struct records{
        uint256 recordsCounter;
        address owner;
        mapping(bytes32 => bytes32) hashes;
        mapping(bytes32 => bytes) recordHashed;
        mapping(uint256 => bytes) record;
    }

    mapping(bytes32 => records) aliases;
    
    modifier onlyOwner{

        require(msg.sender == owner);
        _;

    }

    constructor() public{

        owner = msg.sender;
        commissionAlias = 0;
        commissionRecordHashed = 0;
        commissionRecord = 0;

    }

    function addAlias(bytes32 _aliasHash, bytes32[] memory _names, uint256[] memory _shifts, bytes memory _mixedValues) payable public{

        require(aliases[_aliasHash].owner == address(0));
        require(msg.value >= commissionAlias);
        require(_names.length == _shifts.length);
        aliases[_aliasHash].owner = msg.sender;
        aliases[_aliasHash].recordsCounter = 0;
        uint256 shift = 0;

        for(uint256 i = 0; i < _names.length; i++){

            aliases[_aliasHash].recordHashed[_names[i]] = slice(_mixedValues, shift, _shifts[i]);
            shift += _shifts[i];

        }

    }

    function addRecordHashed(bytes32 _aliasHash, bytes32[] memory _names, bytes32[] memory _values, uint256[] memory _shifts, bytes memory _mixedValues) payable public{

        require(_names.length == _values.length);
        require(_names.length == _shifts.length);
        require(aliases[_aliasHash].owner == msg.sender);
        uint256 commRecords = commissionRecordHashed * _names.length;
        require(msg.value >= commRecords);
        uint256 shift = 0;

        for(uint256 i = 0; i < _names.length; i++){

            if(aliases[_aliasHash].hashes[_names[i]] == _values[i]) continue;
            aliases[_aliasHash].hashes[_names[i]] = _values[i];
            aliases[_aliasHash].recordHashed[_names[i]] = slice(_mixedValues, shift, _shifts[i]);
            shift += _shifts[i];

        }

    }

    function addRecord(bytes32 _aliasHash, uint256[] memory _indexes, uint256[] memory _shifts, bytes memory _mixedValues) payable public{

        require(aliases[_aliasHash].owner == msg.sender);
        uint256 commRecords = commissionRecord * _indexes.length;
        require(msg.value >= commRecords);
        uint256 shift = 0;
        for(uint256 i = 0; i < _indexes.length; i++){
            if(_indexes[i] == 0){
                _indexes[i] = aliases[_aliasHash].recordsCounter; 
                aliases[_aliasHash].recordsCounter++;
            } else {
                _indexes[i] = _indexes[i] - 1;
            }
            require(_indexes[i] < aliases[_aliasHash].recordsCounter);
            aliases[_aliasHash].record[_indexes[i]] = slice(_mixedValues, shift, _shifts[i]);
            shift += _shifts[i];
        }
    }

    function getRecord(bytes32 _aliasHash, uint256 _indexFrom, uint256 _indexTo) public view returns(uint256[] memory shifts, bytes memory mixedResult){

        mixedResult = '';
            
        if (aliases[_aliasHash].owner != address(0)) {
            if(_indexTo > aliases[_aliasHash].recordsCounter) _indexTo = aliases[_aliasHash].recordsCounter;
            if (_indexTo - _indexFrom >= 0) {
                shifts = new uint256[](_indexTo - _indexFrom + 1);
                uint256 shiftIndex = 0;
        
                for(uint256 i = _indexFrom; i <= _indexTo; i++){

                    mixedResult = concat(mixedResult, aliases[_aliasHash].record[i]);
                    shifts[shiftIndex++] = aliases[_aliasHash].record[i].length;

                }            
            }
        }

    }
    function getRecordHashed(bytes32 _aliasHash, bytes32[] memory _names) public view returns(address hashOwner, uint256[] memory shifts, bytes memory mixedResult){

        hashOwner = aliases[_aliasHash].owner;
        mixedResult = '';
        shifts = new uint256[](_names.length);

        for(uint256 i = 0; i < _names.length; i++){
            
            shifts[i] = aliases[_aliasHash].recordHashed[_names[i]].length;
            mixedResult = concat(mixedResult, aliases[_aliasHash].recordHashed[_names[i]]);
            
        }            

    }
    function getRecordsCounter(bytes32 _aliasHash) public view returns(uint256 counter){

        require(aliases[_aliasHash].owner == msg.sender);
        return aliases[_aliasHash].owner == address(0) ? 0 : aliases[_aliasHash].recordsCounter;

    }

    function getHashes(bytes32 _aliasHash, bytes32[] memory _names) public view returns(address hashOwner, bytes32[] memory hashes){

        hashOwner = aliases[_aliasHash].owner;
        hashes = new bytes32[](_names.length);
        for(uint256 i = 0; i < _names.length; i++) hashes[i] = aliases[_aliasHash].hashes[_names[i]];

    }

    function changeParams(uint256 _commissionAlias, uint256 _commissionRecordHashed, uint256 _commissionRecord) onlyOwner public{
        
        commissionAlias = _commissionAlias;
        commissionRecordHashed = _commissionRecordHashed;
        commissionRecord = _commissionRecord;

    }

    function getParams() public view returns(uint256 commAlias, uint256 commRecordHashed, uint256 commRecord){
        
        commAlias = commissionAlias;
        commRecordHashed = commissionRecordHashed;
        commRecord = commissionRecord;

    }

    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns(bytes memory){

        require(_bytes.length >= (_start + _length));
        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(_length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)
                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }
                mstore(tempBytes, _length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;

    }

    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns(bytes memory){
    
        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)
            let length := mload(_preBytes)
            mstore(tempBytes, length)
            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)
            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))
            mc := end
            end := add(mc, length)
            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }
    
    function withdraw(address payable _receiver) public onlyOwner{
        
        _receiver.transfer(address(this).balance);
        
    }
    
}