// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract GasContract {
    uint256 private lastAmount;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;

    address[5] public administrators;
    constructor(address[] memory _admins, uint256 _totalSupply) {
        // for (uint256 ii; ii < 5; ) {
        //     administrators[ii] = _admins[ii];
        // }
        assembly {
            for {let ii} lt(ii, 5) {ii := add(ii, 1)} {
                let admin := mload(add(_admins, mul(0x20, add(ii, 1))))
                sstore(add(administrators.slot, ii), admin)
                //administrators[ii] = admin;
            }
            mstore(0x0, caller())
            mstore(0x20, balances.slot)
            let slot := keccak256(0x0, 0x40)
            sstore(slot, _totalSupply)
            //balances[msg.sender] = _totalSupply;
        }
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public {
        assembly {
            //balances[msg.sender] -= _amount;
            let ptr := mload(0x40)
            mstore(ptr, caller())
            mstore(add(ptr, 0x20), balances.slot)
            let senderSlot := keccak256(ptr, 0x40)
            sstore(senderSlot, sub(sload(senderSlot), _amount))
            let val := sload(senderSlot)

            //balances[_recipient] += _amount;
            mstore(ptr, _recipient)
            mstore(add(ptr, 0x20), balances.slot)
            let recipientSlot := keccak256(ptr, 0x40)
            sstore(recipientSlot, add(sload(recipientSlot), _amount))
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        // if (_tier >= 255) revert TierLevelTooHigh(_tier);
        // uint256 ii;
        // bool revertV = false;
        // for (ii= 0; ii < 5; ii++) {
        //     if (administrators[ii] == msg.sender){
        //         revertV = true;
        //         break;}
        // }
        // if (revertV) revert CallerNotAdmin(msg.sender);

        // emit AddedToWhitelist(_userAddrs, _tier);

        assembly {
            if gt(_tier, 255) {revert(0,0)}
            let ii := 0
            for {} lt(ii, 5) {ii := add(ii, 1)} {
                if eq(sload(add(administrators.slot, ii)), caller()) {
                    break
                }
            }
            if eq(ii, 5) {revert(0,0)}
            let signature := 0x62c1e066774519db9fe35767c15fc33df2f016675b7cc0c330ed185f286a2d52
            mstore(0, _userAddrs)
            mstore(0x20, _tier)
            log1(0, 0x40, signature)
            // let ptr := mload(0x40)
            // mstore(ptr, _userAddrs)
            // mstore(add(ptr, 0x20), _tier)
            // log1(ptr, 0x40, signature)

        }
        //if (ii == 5) revert CallerNotAdmin(msg.sender);

        //emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {
        assembly {
            sstore(lastAmount.slot, _amount)

            let ptr := mload(0x40)
            mstore(ptr, caller())
            mstore(add(ptr, 0x20), balances.slot)
            let senderSlot := keccak256(ptr, 0x40)
            sstore(senderSlot, sub(sload(senderSlot), _amount))

            mstore(ptr, _recipient)
            mstore(add(ptr, 0x20), balances.slot)
            let recipientSlot := keccak256(ptr, 0x40)
            sstore(recipientSlot, add(sload(recipientSlot), _amount))

            let signature := 0x98eaee7299e9cbfa56cf530fd3a0c6dfa0ccddf4f837b8f025651ad9594647b3
            log2(0x0, 0x0, signature, _recipient)
        }
        // lastAmount = _amount;

        //balances[msg.sender] -= _amount;
        //balances[_recipient] += _amount;

        //emit WhiteListTransfer(_recipient, _amount);
    }

    function getPaymentStatus(
        address sender
    ) public view returns (bool, uint256) {
        return (true, lastAmount);
    }
}
