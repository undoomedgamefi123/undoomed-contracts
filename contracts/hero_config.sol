// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct PubConfig {
    uint256 heroId;
    uint256 atkValueLow;
    uint256 atkValueUp;
    uint256 atkSpeedLow;
    uint256 atkSpeedUp;
    uint256 magicValueLow;
    uint256 magicValueUp;
}

struct AbilityScore {
    uint256 atkValue;
    uint256 atkSpeed;
    uint256 magicValue;
}

struct HeroInfo {
    string heroName;
    uint256 level;
    uint256 quality;
    uint256 occupation;
    uint256 atkValue;
    uint256 atkSpeed;
    uint256 magicValue;
    bool isPledged;
    bool isAdventuring;
    uint256 summoner;
    uint256 heroId;
    uint256 model;
}

struct UpgradeAttribute {
    uint256 upCost;
    uint256 upCost2;
    uint256 armyLevel;
    uint256 recoveryPay;
}

contract HeroConfig {
    function initAbilityScore(uint256 _quality, uint256 _occupation)
        external
        pure
        returns (PubConfig memory _x)
    {
        if (_quality == 1 && _occupation == 1) {
            return PubConfig(1001, 25, 40, 18, 28, 10, 16);
        } else if (_quality == 2 && _occupation == 1) {
            return PubConfig(1002, 40, 55, 28, 39, 16, 22);
        } else if (_quality == 3 && _occupation == 1) {
            return PubConfig(1003, 55, 70, 39, 49, 22, 28);
        } else if (_quality == 4 && _occupation == 1) {
            return PubConfig(1004, 70, 85, 49, 60, 28, 34);
        } else if (_quality == 5 && _occupation == 1) {
            return PubConfig(1005, 85, 100, 60, 70, 34, 40);
        } else if (_quality == 1 && _occupation == 2) {
            return PubConfig(1101, 15, 24, 13, 20, 25, 40);
        } else if (_quality == 2 && _occupation == 2) {
            return PubConfig(1102, 24, 33, 20, 28, 40, 55);
        } else if (_quality == 3 && _occupation == 2) {
            return PubConfig(1103, 33, 42, 28, 35, 55, 70);
        } else if (_quality == 4 && _occupation == 2) {
            return PubConfig(1104, 42, 51, 35, 43, 70, 85);
        } else if (_quality == 5 && _occupation == 2) {
            return PubConfig(1105, 51, 60, 43, 50, 85, 100);
        } else if (_quality == 1 && _occupation == 3) {
            return PubConfig(1201, 18, 28, 25, 40, 10, 16);
        } else if (_quality == 2 && _occupation == 3) {
            return PubConfig(1202, 28, 39, 40, 55, 16, 22);
        } else if (_quality == 3 && _occupation == 3) {
            return PubConfig(1203, 39, 49, 55, 70, 22, 28);
        } else if (_quality == 4 && _occupation == 3) {
            return PubConfig(1204, 49, 60, 70, 85, 28, 34);
        } else if (_quality == 5 && _occupation == 3) {
            return PubConfig(1205, 60, 70, 85, 100, 34, 40);
        }
    }

    function getUpgradeAttribute(uint256 _level)
        external
        pure
        returns (UpgradeAttribute memory attr)
    {
        if (_level == 1) {
            return UpgradeAttribute(4000, 20, 1, 500);
        } else if (_level == 2) {
            return UpgradeAttribute(8000, 50, 2, 1000);
        } else if (_level == 3) {
            return UpgradeAttribute(16000, 100, 3, 2000);
        } else if (_level == 4) {
            return UpgradeAttribute(32000, 200, 4, 4000);
        } else if (_level == 5) {
            return UpgradeAttribute(64000, 400, 5, 8000);
        } else if (_level == 6) {
            return UpgradeAttribute(96000, 600, 5, 16000);
        } else if (_level == 7) {
            return UpgradeAttribute(128000, 800, 5, 24000);
        } else if (_level == 8) {
            return UpgradeAttribute(0, 0, 5, 32000);
        }
    }
}
