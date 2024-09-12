
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import {vm as hevm} from "@chimera/Hevm.sol";

contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    function testSumOfAssets() public {

        setSenderAddr(address(0x20000));
        deposit(115792089237316195423570985008687907853269984665640564039457584007907629891202);

        setSenderAddr(address(0x30000));
        deposit(82548787732489930966595887242219430396922353139416759276498465888425098196844);

        donate(73035438358962359599247245535717644510293383980530700180393992014309840921968, true);

        setSenderAddr(address(0x20000));
        redeem(97);

        sum_of_user_assets_equals_total_assets();    
    }

    function testRedeemBroken() public {
        deposit(256);
        deposit(256);
        deposit(256);
        rewardAccrual(48743027362908275024177206706784719477041320055056926501611499549379336479930);
        total_assets_below_total_balance();
        redeem(14081555324802609486282391161562502039823688373);
        redeem(115792089237316195423570947188336821530327016604520359646366510738258800234672);
        redeem(115792089237316195423570985008687907853269984665640564039457584007907629891202);
        redeem(28335242420548078672872055242204429141836419187246766682602465188520481368254);
        redeem(108050672534864268963763294832020623833014451888420460187005423476058046575279);
        redeem(115792089237316195423570985008687907853269984665640564038157584007913129640436);
    }
}
