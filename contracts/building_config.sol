// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct BuildingAttribute {
    BuildingFunctionType functionType;
    uint256 pledgeLimit;
    uint256 createCrystalCost;
    uint256 createCroesusCost;
    uint256 pledgeLevel;
    uint256 population;
    uint256 baseRate;
    uint256 pledgeQuality;
}

enum BuildingFunctionType {
    Army,
    Economy,
    Other
}

contract BuildingConfig {
    function getInitialBuildingIds()
        external
        pure
        returns (uint256[10] memory ids)
    {
        return [
            uint256(6001),
            6006,
            6007,
            6010,
            6011,
            6012,
            6013,
            6014,
            6015,
            6016
        ];
    }

    function getEconomyBuildingIds()
        external
        pure
        returns (uint256[3] memory ids)
    {
        return [uint256(6007), 6008, 6009];
    }

    function buildingById(uint256 id)
        external
        pure
        returns (BuildingAttribute memory equipment)
    {
        if (id == 6001) {
            return building_6001();
        } else if (id == 6002) {
            return building_6002();
        } else if (id == 6003) {
            return building_6003();
        } else if (id == 6004) {
            return building_6004();
        } else if (id == 6005) {
            return building_6005();
        } else if (id == 6006) {
            return building_6006();
        } else if (id == 6007) {
            return building_6007();
        } else if (id == 6008) {
            return building_6008();
        } else if (id == 6009) {
            return building_6009();
        } else if (id == 6010) {
            return building_6010();
        } else if (id == 6011) {
            return building_6011();
        } else if (id == 6012) {
            return building_6012();
        } else if (id == 6013) {
            return building_6013();
        } else if (id == 6014) {
            return building_6014();
        } else if (id == 6015) {
            return building_6015();
        } else if (id == 6016) {
            return building_6016();
        }
    }

    function getAllBuildingIds() external pure returns (uint256[16] memory) {
        return [
            uint256(6001),
            6002,
            6003,
            6004,
            6005,
            6006,
            6007,
            6008,
            6009,
            6010,
            6011,
            6012,
            6013,
            6014,
            6015,
            6016
        ];
    }

    function building_6001() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Army,
                100,
                0,
                0,
                0,
                60,
                20,
                0
            );
    }

    function building_6002() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Army,
                300,
                15000,
                100,
                0,
                36,
                12,
                0
            );
    }

    function building_6003() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Army,
                600,
                30000,
                300,
                0,
                24,
                8,
                0
            );
    }

    function building_6004() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Army,
                1000,
                60000,
                600,
                0,
                12,
                4,
                0
            );
    }

    function building_6005() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Army,
                1500,
                90000,
                1000,
                0,
                6,
                2,
                0
            );
    }

    function building_6006() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6007() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Economy,
                5000,
                0,
                0,
                0,
                10,
                500,
                0
            );
    }

    function building_6008() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Economy,
                5000,
                30000,
                500,
                3,
                10,
                1000,
                3
            );
    }

    function building_6009() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(
                BuildingFunctionType.Economy,
                5000,
                100000,
                1000,
                5,
                5,
                2000,
                4
            );
    }

    function building_6010() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6011() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6012() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6013() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6014() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6015() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }

    function building_6016() public pure returns (BuildingAttribute memory) {
        return
            BuildingAttribute(BuildingFunctionType.Other, 0, 0, 0, 0, 0, 0, 0);
    }
}
