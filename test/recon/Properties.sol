
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";
import "forge-std/console.sol";

abstract contract Properties is Setup, Asserts {
    function total_balance_below_actual_balance() public returns (bool) {
        t(mockEbtc.balanceOf(address(stakedEbtc)) >= stakedEbtc.totalBalance(), "actualBalance >= totalBalance");
    }

    function total_assets_below_total_balance() public returns (bool) {
        t(stakedEbtc.totalBalance() >= stakedEbtc.totalAssets(), "totalBalance >= totalAssets");
    }

    function sum_of_user_balances_equals_total_supply() public returns (bool) {
        uint256 sumOfUserBalances;
        for (uint256 i; i < senders.length; i++) {
            sumOfUserBalances += stakedEbtc.balanceOf(senders[i]);
        }
        t(sumOfUserBalances == stakedEbtc.totalSupply(), "sumOfUserBalances == totalSupply");
    }

    function sum_of_user_assets_equals_total_assets() public returns (bool) {
        uint256 sumOfUserAssets;
        for (uint256 i; i < senders.length; i++) {
            sumOfUserAssets += stakedEbtc.convertToAssets(stakedEbtc.balanceOf(senders[i]));
        }
        console.log("sumOfUserAssets", sumOfUserAssets);
        console.log("stakedEbtc.totalAssets()", stakedEbtc.totalAssets());
        t(sumOfUserAssets == stakedEbtc.totalAssets(), "sumOfUserAssets == totalAssets");
    }
}
