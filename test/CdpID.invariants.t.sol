// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";


contract CDPID is Test {

    uint256 shares;
    
    uint256 stFPPSg;

    uint256 newIndex;

    uint256 constant DECIMAL_PRECISION = 1e18;

    uint256 totalEthInVault;
    uint256 totalShares;


    function setUp() public {
        stFPPSg = 1e18;

        shares = 100e18;

        newIndex = stFPPSg + 1e17;

        totalEthInVault = 100e18;
        totalShares = 100e18;
    }

    function increaseIndex() public {
        newIndex = stFPPSg + 1e17; // 10%
    }


    function getEntireSystemColl() public view returns (uint) { 
        return shares;
    }

    function _syncIndex() internal returns (uint _oldIndex, uint _newIndex) {
        _oldIndex = stFPPSg;
         increaseValueOfShares();
        _newIndex = getPooledEthByShares(1e18);
    }

    function increaseValueOfShares() public returns (uint256) {
        emit Debug("increaseValueOfShares");
        totalEthInVault += totalEthInVault * 10 / 100;
    }


    function getSharesByPooledEth(uint256 ethAmount) public view returns (uint256) {
        if(totalEthInVault == 0) {
            return ethAmount;
        }
        return ethAmount * totalShares / totalEthInVault;
    }

    function getPooledEthByShares(uint256 sharesAmount) public view returns (uint256) {
        if(totalShares == 0){
            return 0;
        }
        return sharesAmount * totalEthInVault / totalShares;
    }

    function getOldPooledEthByShares(uint256 sharesAmount, uint256 oldIndex) public view returns (uint256) {
        if(totalShares == 0){
            return 0;
        }
        return sharesAmount * oldIndex;
    }





    event Debug(string name);
    event Debug(string name, uint256);

    function testTheSplit() public {
        (uint256 stale, uint256 updated) = _syncIndex();
        emit Debug("1");
        uint256 deltaIndex = updated - stale;
        uint256 deltaIndexFees = deltaIndex * 2_500 / 10_000;
        emit Debug("1a");
        uint256 _deltaFeeSplit = deltaIndexFees * (getEntireSystemColl()); 
        emit Debug("2");
        uint256 _feeTaken = getSharesByPooledEth(_deltaFeeSplit) / DECIMAL_PRECISION;
        emit Debug("_feeTaken", _feeTaken);

        // Compare vs taking the fee on the whole collateral
        uint256 wholeCollat = getOldPooledEthByShares(getEntireSystemColl(), updated);
        emit Debug("4");
        uint256 beforeWholeCollat = getOldPooledEthByShares(getEntireSystemColl(), stale);
        uint256 totalDiff = wholeCollat - beforeWholeCollat;
        uint256 simpleFeeTaken = totalDiff * 2_500 / 10_000 / DECIMAL_PRECISION;

        assertEq(_feeTaken, simpleFeeTaken);
    }

     

}
