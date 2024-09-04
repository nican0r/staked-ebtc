// SPDX-License-Identifier: ISC
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IGnosisSafe } from "../src/Dependencies/IGnosisSafe.sol";
import { Governor } from "../src/Dependencies/Governor.sol";
import { StakedEbtc } from "../src/StakedEbtc.sol";
import { FeeRecipientDonationModule } from "../src/FeeRecipientDonationModule.sol";

contract TestDonationModule is Test {

    StakedEbtc public stakedEbtc;
    uint256 public rewardsCycleLength;
    FeeRecipientDonationModule public donationModule;

    function setUp() public virtual {
        address ebtcToken = 0x661c70333AA1850CcDBAe82776Bb436A0fCfeEfB;
        uint256 TEN_PERCENT = 3_022_266_030; // per second rate compounded week each block (1.10^(365 * 86400 / 12) - 1) / 12 * 1e18

        Governor governor = Governor(0x2A095d44831C26cFB6aCb806A6531AE3CA32DBc1);

        stakedEbtc = new StakedEbtc({
            _underlying: IERC20(ebtcToken),
            _name: "Staked Ebtc",
            _symbol: "stEbtc",
            _rewardsCycleLength: 7 days,
            _maxDistributionPerSecondPerAsset: TEN_PERCENT,
            _authorityAddress: address(governor)
        });
        
        donationModule = new FeeRecipientDonationModule({
            _steBtc: address(stakedEbtc),
            _dex:  0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            _guardian: 0x690C74AF48BE029e763E61b4aDeB10E06119D3ba,
            _annualizedYieldBPS: 500,
            _swapSlippageBPS: 100,
            _swapPath: abi.encodePacked(
                0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0,
                uint24(100),
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                uint24(500),
                0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
                uint24(500),
                ebtcToken
            )
        });

        IGnosisSafe safe = IGnosisSafe(0x2CEB95D4A67Bf771f1165659Df3D11D8871E906f);

        // high-sec timelock
        vm.startPrank(0xaDDeE229Bd103bb5B10C3CdB595A01c425dd3264);
        governor.setRoleCapability(12, address(stakedEbtc), StakedEbtc.setMaxDistributionPerSecondPerAsset.selector, true);
        governor.setRoleCapability(12, address(stakedEbtc), StakedEbtc.donate.selector, true);
        governor.setRoleCapability(12, address(stakedEbtc), StakedEbtc.sweep.selector, true);
        governor.setRoleCapability(12, address(stakedEbtc), StakedEbtc.setMinRewardsPerPeriod.selector, true);
        governor.setUserRole(address(safe), 12, true);
        vm.stopPrank();

        // enable safe module
        vm.prank(address(safe));
        safe.enableModule(address(donationModule));
    }

    function testCalculateDonationAmount() public {
        vm.startPrank(address(0), address(0));
        (bool upkeepNeeded, bytes memory performData) = donationModule.checkUpkeep("");
        vm.stopPrank();

        console.log(upkeepNeeded);
        console.logBytes(performData);

        console.log("totalBalanceBefore", stakedEbtc.totalBalance());

        vm.prank(donationModule.CHAINLINK_KEEPER_REGISTRY());
        donationModule.performUpkeep(performData);

        console.log("totalBalanceAfter", stakedEbtc.totalBalance());
    }
}

