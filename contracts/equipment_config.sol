// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct EquipmentAttribute {
    uint32 position;
    uint32 atkValue;
    uint32 atkSpeed;
    uint32 magicValue;
    uint32 atkRange;
    uint32 castleDefense;
    uint32 addGold;
    uint32 reduceSpell;
    uint32 magicRecover;
    uint32 army1Atk;
    uint32 army2Atk;
    uint32 army3Atk;
    uint32 army4Atk;
    uint32 army5Atk;
    uint32 allType;
}

contract EquipmentConfig {
    function equipmentById(uint256 id)
        external
        pure
        returns (EquipmentAttribute memory equipment)
    {
        if (id == 4101) {
            return equipment_4101();
        } else if (id == 4102) {
            return equipment_4102();
        } else if (id == 4103) {
            return equipment_4103();
        } else if (id == 4104) {
            return equipment_4104();
        } else if (id == 4105) {
            return equipment_4105();
        } else if (id == 4106) {
            return equipment_4106();
        } else if (id == 4201) {
            return equipment_4201();
        } else if (id == 4012) {
            return equipment_4012();
        } else if (id == 4013) {
            return equipment_4013();
        } else if (id == 4014) {
            return equipment_4014();
        } else if (id == 4015) {
            return equipment_4015();
        } else if (id == 4016) {
            return equipment_4016();
        } else if (id == 4601) {
            return equipment_4601();
        } else if (id == 4602) {
            return equipment_4602();
        } else if (id == 4603) {
            return equipment_4603();
        } else if (id == 4604) {
            return equipment_4604();
        } else if (id == 4605) {
            return equipment_4605();
        } else if (id == 4606) {
            return equipment_4606();
        } else if (id == 4501) {
            return equipment_4501();
        } else if (id == 4502) {
            return equipment_4502();
        } else if (id == 4503) {
            return equipment_4503();
        } else if (id == 4504) {
            return equipment_4504();
        } else if (id == 4505) {
            return equipment_4505();
        } else if (id == 4506) {
            return equipment_4506();
        } else if (id == 4301) {
            return equipment_4301();
        } else if (id == 4302) {
            return equipment_4302();
        } else if (id == 4303) {
            return equipment_4303();
        } else if (id == 4304) {
            return equipment_4304();
        } else if (id == 4305) {
            return equipment_4305();
        } else if (id == 4306) {
            return equipment_4306();
        } else if (id == 4401) {
            return equipment_4401();
        } else if (id == 4402) {
            return equipment_4402();
        } else if (id == 4403) {
            return equipment_4403();
        } else if (id == 4404) {
            return equipment_4404();
        } else if (id == 4405) {
            return equipment_4405();
        } else if (id == 4406) {
            return equipment_4406();
        } else if (id == 4701) {
            return equipment_4701();
        } else if (id == 4702) {
            return equipment_4702();
        } else if (id == 4703) {
            return equipment_4703();
        } else if (id == 4704) {
            return equipment_4704();
        } else if (id == 4705) {
            return equipment_4705();
        } else if (id == 4706) {
            return equipment_4706();
        } else if (id == 4001) {
            return equipment_4001();
        } else if (id == 4002) {
            return equipment_4002();
        } else if (id == 4003) {
            return equipment_4003();
        } else if (id == 4004) {
            return equipment_4004();
        } else if (id == 4005) {
            return equipment_4005();
        } else if (id == 4006) {
            return equipment_4006();
        } else if (id == 4007) {
            return equipment_4007();
        } else if (id == 4008) {
            return equipment_4008();
        } else if (id == 4009) {
            return equipment_4009();
        } else if (id == 4010) {
            return equipment_4010();
        } else if (id == 4011) {
            return equipment_4011();
        }
    }

    function equipment_4101() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4102() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4103() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4104() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4105() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4106() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(1, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4201() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4012() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4013() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4014() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4015() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4016() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(2, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4601() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4602() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4603() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4604() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4605() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4606() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(3, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4501() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4502() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4503() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4504() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4505() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4506() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(4, 0, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4301() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4302() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(5, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4303() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(5, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4304() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4305() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(5, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4306() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(5, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4401() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4402() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4403() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4404() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4405() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4406() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(6, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4701() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4702() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4703() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4704() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4705() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4706() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(7, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4001() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(8, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4002() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(8, 0, 0, 0, 0, 0, 200, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4003() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(8, 0, 0, 0, 0, 0, 300, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4004() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(8, 0, 0, 0, 0, 0, 400, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4005() public pure returns (EquipmentAttribute memory) {
        return
            EquipmentAttribute(8, 0, 0, 0, 0, 0, 500, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    function equipment_4006() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0);
    }

    function equipment_4007() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0);
    }

    function equipment_4008() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0);
    }

    function equipment_4009() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0);
    }

    function equipment_4010() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0);
    }

    function equipment_4011() public pure returns (EquipmentAttribute memory) {
        return EquipmentAttribute(8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
    }
}
