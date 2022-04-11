// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct ItemAttribute {
    uint256 position;
    uint256 level;
    uint256 itemType;
    uint256 recoveryPayNumber;
    uint256 stack;
    string name;
}

contract ItemConfig {
    function mergeRequireItemsById(uint256 id)
        external
        pure
        returns (uint256[5] memory ids)
    {
        if (id == 4106) {
            return [uint256(4101), 4102, 4103, 4104, 4105];
        } else if (id == 4206) {
            return [uint256(4201), 4202, 4203, 4204, 4205];
        } else if (id == 4606) {
            return [uint256(4601), 4602, 4603, 4604, 4605];
        } else if (id == 4506) {
            return [uint256(4501), 4502, 4503, 4504, 4505];
        } else if (id == 4306) {
            return [uint256(4301), 4302, 4303, 4304, 4305];
        } else if (id == 4406) {
            return [uint256(4401), 4402, 4403, 4404, 4405];
        } else if (id == 4706) {
            return [uint256(4701), 4702, 4703, 4704, 4705];
        } else if (id == 4006) {
            return [uint256(4001), 4002, 4003, 4004, 4005];
        } else if (id == 4012) {
            return [uint256(4007), 4008, 4009, 4010, 4011];
        } else if (id == 4801) {
            return [uint256(8102), 8110, 8111, 8116, 8121];
        } else if (id == 4802) {
            return [uint256(8103), 8109, 8113, 8120, 8124];
        } else if (id == 4803) {
            return [uint256(8104), 8106, 8115, 8118, 8125];
        } else if (id == 4804) {
            return [uint256(8105), 8107, 8114, 8117, 8122];
        } else if (id == 4805) {
            return [uint256(8101), 8108, 8112, 8119, 8123];
        }
    }

    function equipmentItemIdsByLevel(uint256 level)
        external
        pure
        returns (uint256[] memory ids)
    {
        if (level == 1) {
            return equipmentLevel1Ids();
        } else if (level == 2) {
            return equipmentLevel2Ids();
        } else if (level == 3) {
            return equipmentLevel3Ids();
        } else if (level == 4) {
            return equipmentLevel4Ids();
        } else if (level == 5) {
            return equipmentLevel5Ids();
        }
    }

    function skillItemIdsByLevel(uint256 level)
        external
        pure
        returns (uint256[] memory ids)
    {
        if (level == 1) {
            return skillLevel1Ids();
        } else if (level == 2) {
            return skillLevel2Ids();
        } else if (level == 3) {
            return skillLevel3Ids();
        } else if (level == 4) {
            return skillLevel4Ids();
        } else if (level == 5) {
            return skillLevel5Ids();
        }
    }

    function equipmentLevel1Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](9);
        ids[0] = 4101;
        ids[1] = 4201;
        ids[2] = 4601;
        ids[3] = 4501;
        ids[4] = 4301;
        ids[5] = 4401;
        ids[6] = 4701;
        ids[7] = 4001;
        ids[8] = 4307;
    }

    function equipmentLevel2Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](9);
        ids[0] = 4102;
        ids[1] = 4202;
        ids[2] = 4602;
        ids[3] = 4502;
        ids[4] = 4302;
        ids[5] = 4402;
        ids[6] = 4702;
        ids[7] = 4002;
        ids[8] = 4308;
    }

    function equipmentLevel3Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](9);
        ids[0] = 4103;
        ids[1] = 4203;
        ids[2] = 4603;
        ids[3] = 4503;
        ids[4] = 4303;
        ids[5] = 4403;
        ids[6] = 4703;
        ids[7] = 4003;
        ids[8] = 4309;
    }

    function equipmentLevel4Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](14);
        ids[0] = 4104;
        ids[1] = 4204;
        ids[2] = 4604;
        ids[3] = 4504;
        ids[4] = 4304;
        ids[5] = 4404;
        ids[6] = 4704;
        ids[7] = 4004;
        ids[9] = 4007;
        ids[8] = 4008;
        ids[10] = 4009;
        ids[11] = 4010;
        ids[12] = 4011;
        ids[13] = 4310;
    }

    function equipmentLevel5Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](9);
        ids[0] = 4105;
        ids[1] = 4205;
        ids[2] = 4605;
        ids[3] = 4505;
        ids[4] = 4305;
        ids[5] = 4405;
        ids[6] = 4705;
        ids[7] = 4005;
        ids[8] = 4311;
    }

    function skillLevel1Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](5);
        ids[0] = 8101;
        ids[1] = 8102;
        ids[2] = 8103;
        ids[3] = 8104;
        ids[4] = 8105;
    }

    function skillLevel2Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](5);
        ids[0] = 8106;
        ids[1] = 8107;
        ids[2] = 8108;
        ids[3] = 8109;
        ids[4] = 8110;
    }

    function skillLevel3Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](5);
        ids[0] = 8111;
        ids[1] = 8112;
        ids[2] = 8113;
        ids[3] = 8114;
        ids[4] = 8115;
    }

    function skillLevel4Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](5);
        ids[0] = 8116;
        ids[1] = 8117;
        ids[2] = 8118;
        ids[3] = 8119;
        ids[4] = 8120;
    }

    function skillLevel5Ids() public pure returns (uint256[] memory ids) {
        ids = new uint256[](5);
        ids[0] = 8121;
        ids[1] = 8122;
        ids[2] = 8123;
        ids[3] = 8124;
        ids[4] = 8125;
    }

    function itemById(uint256 id)
        external
        pure
        returns (ItemAttribute memory equipment)
    {
        if (id == 4101) {
            return item_4101();
        } else if (id == 4102) {
            return item_4102();
        } else if (id == 4103) {
            return item_4103();
        } else if (id == 4104) {
            return item_4104();
        } else if (id == 4105) {
            return item_4105();
        } else if (id == 4106) {
            return item_4106();
        } else if (id == 4201) {
            return item_4201();
        } else if (id == 4202) {
            return item_4202();
        } else if (id == 4203) {
            return item_4203();
        } else if (id == 4204) {
            return item_4204();
        } else if (id == 4205) {
            return item_4205();
        } else if (id == 4206) {
            return item_4206();
        } else if (id == 4601) {
            return item_4601();
        } else if (id == 4602) {
            return item_4602();
        } else if (id == 4603) {
            return item_4603();
        } else if (id == 4604) {
            return item_4604();
        } else if (id == 4605) {
            return item_4605();
        } else if (id == 4606) {
            return item_4606();
        } else if (id == 4501) {
            return item_4501();
        } else if (id == 4502) {
            return item_4502();
        } else if (id == 4503) {
            return item_4503();
        } else if (id == 4504) {
            return item_4504();
        } else if (id == 4505) {
            return item_4505();
        } else if (id == 4506) {
            return item_4506();
        } else if (id == 4301) {
            return item_4301();
        } else if (id == 4302) {
            return item_4302();
        } else if (id == 4303) {
            return item_4303();
        } else if (id == 4304) {
            return item_4304();
        } else if (id == 4305) {
            return item_4305();
        } else if (id == 4306) {
            return item_4306();
        } else if (id == 4307) {
            return item_4307();
        } else if (id == 4308) {
            return item_4308();
        } else if (id == 4309) {
            return item_4309();
        } else if (id == 4310) {
            return item_4310();
        } else if (id == 4311) {
            return item_4311();
        } else if (id == 4312) {
            return item_4312();
        } else if (id == 4401) {
            return item_4401();
        } else if (id == 4402) {
            return item_4402();
        } else if (id == 4403) {
            return item_4403();
        } else if (id == 4404) {
            return item_4404();
        } else if (id == 4405) {
            return item_4405();
        } else if (id == 4406) {
            return item_4406();
        } else if (id == 4701) {
            return item_4701();
        } else if (id == 4702) {
            return item_4702();
        } else if (id == 4703) {
            return item_4703();
        } else if (id == 4704) {
            return item_4704();
        } else if (id == 4705) {
            return item_4705();
        } else if (id == 4706) {
            return item_4706();
        } else if (id == 4001) {
            return item_4001();
        } else if (id == 4002) {
            return item_4002();
        } else if (id == 4003) {
            return item_4003();
        } else if (id == 4004) {
            return item_4004();
        } else if (id == 4005) {
            return item_4005();
        } else if (id == 4006) {
            return item_4006();
        } else if (id == 4007) {
            return item_4007();
        } else if (id == 4008) {
            return item_4008();
        } else if (id == 4009) {
            return item_4009();
        } else if (id == 4010) {
            return item_4010();
        } else if (id == 4011) {
            return item_4011();
        } else if (id == 4012) {
            return item_4012();
        } else if (id == 8101) {
            return item_8101();
        } else if (id == 8102) {
            return item_8102();
        } else if (id == 8103) {
            return item_8103();
        } else if (id == 8104) {
            return item_8104();
        } else if (id == 8105) {
            return item_8105();
        } else if (id == 8106) {
            return item_8106();
        } else if (id == 8107) {
            return item_8107();
        } else if (id == 8108) {
            return item_8108();
        } else if (id == 8109) {
            return item_8109();
        } else if (id == 8110) {
            return item_8110();
        } else if (id == 8111) {
            return item_8111();
        } else if (id == 8112) {
            return item_8112();
        } else if (id == 8113) {
            return item_8113();
        } else if (id == 8114) {
            return item_8114();
        } else if (id == 8115) {
            return item_8115();
        } else if (id == 8116) {
            return item_8116();
        } else if (id == 8117) {
            return item_8117();
        } else if (id == 8118) {
            return item_8118();
        } else if (id == 8119) {
            return item_8119();
        } else if (id == 8120) {
            return item_8120();
        } else if (id == 8121) {
            return item_8121();
        } else if (id == 8122) {
            return item_8122();
        } else if (id == 8123) {
            return item_8123();
        } else if (id == 8124) {
            return item_8124();
        } else if (id == 8125) {
            return item_8125();
        } else if (id == 4801) {
            return item_4801();
        } else if (id == 4802) {
            return item_4802();
        } else if (id == 4803) {
            return item_4803();
        } else if (id == 4804) {
            return item_4804();
        } else if (id == 4805) {
            return item_4805();
        }
    }

    function item_4101() public pure returns (ItemAttribute memory) {
        return ItemAttribute(1, 1, 2, 1000, 1, "\u77ee\u4eba\u738b\u76fe");
    }

    function item_4102() public pure returns (ItemAttribute memory) {
        return ItemAttribute(1, 2, 2, 2000, 1, "\u72fc\u4eba\u738b\u76fe");
    }

    function item_4103() public pure returns (ItemAttribute memory) {
        return ItemAttribute(1, 3, 2, 3000, 1, "\u7130\u91d1\u9970\u76fe");
    }

    function item_4104() public pure returns (ItemAttribute memory) {
        return ItemAttribute(1, 4, 2, 4000, 1, "\u5723\u5251\u4e4b\u76fe");
    }

    function item_4105() public pure returns (ItemAttribute memory) {
        return ItemAttribute(1, 5, 2, 5000, 1, "\u9f99\u76fe");
    }

    function item_4106() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(1, 5, 2, 15000, 1, "\u5b88\u62a4\u795e\u4e4b\u76fe");
    }

    function item_4201() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 1, 2, 1000, 1, "\u7b26\u6587\u6218\u65a7");
    }

    function item_4202() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 2, 2, 2000, 1, "\u9ed1\u9b54\u5251");
    }

    function item_4203() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 3, 2, 3000, 1, "\u5965\u672f\u6cd5\u6756");
    }

    function item_4204() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 4, 2, 4000, 1, "\u5178\u8303\u4e4b\u5f29");
    }

    function item_4205() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 5, 2, 5000, 1, "\u708e\u9f99\u706b\u820c");
    }

    function item_4206() public pure returns (ItemAttribute memory) {
        return ItemAttribute(2, 5, 2, 15000, 1, "\u6cf0\u5766\u4e4b\u5251");
    }

    function item_4601() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 1, 2, 1000, 1, "\u98ce\u901f\u9774");
    }

    function item_4602() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 2, 2, 2000, 1, "\u795e\u884c\u9774");
    }

    function item_4603() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 3, 2, 3000, 1, "\u6b7b\u795e\u9774");
    }

    function item_4604() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 4, 2, 4000, 1, "\u5929\u7fbd\u9774");
    }

    function item_4605() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 5, 2, 5000, 1, "\u5723\u9774");
    }

    function item_4606() public pure returns (ItemAttribute memory) {
        return ItemAttribute(3, 5, 2, 15000, 1, "\u5929\u8d50\u795e\u8db3");
    }

    function item_4501() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 1, 2, 1000, 1, "\u795e\u517d\u4e4b\u51a0");
    }

    function item_4502() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 2, 2, 2000, 1, "\u542f\u8fea\u5934\u5dfe");
    }

    function item_4503() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 3, 2, 3000, 1, "\u6df7\u6c8c\u4e4b\u51a0");
    }

    function item_4504() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 4, 2, 4000, 1, "\u667a\u6167\u4e4b\u51a0");
    }

    function item_4505() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 5, 2, 5000, 1, "\u5730\u72f1\u738b\u51a0");
    }

    function item_4506() public pure returns (ItemAttribute memory) {
        return ItemAttribute(4, 5, 2, 15000, 1, "\u96f7\u795e\u4e4b\u51a0");
    }

    function item_4301() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(5, 1, 2, 1000, 1, "\u65e0\u540d\u82f1\u96c4\u7532");
    }

    function item_4302() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 2, 2, 2000, 1, "\u7384\u94c1\u6218\u7532");
    }

    function item_4303() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 3, 2, 3000, 1, "\u5148\u77e5\u957f\u888d");
    }

    function item_4304() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 4, 2, 4000, 1, "\u4f51\u62a4\u957f\u888d");
    }

    function item_4305() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 5, 2, 5000, 1, "\u94c1\u8840\u6218\u7532");
    }

    function item_4306() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 5, 2, 15000, 1, "\u5de8\u4eba\u6218\u7532");
    }

    function item_4307() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 1, 2, 1000, 1, "\u9ec4\u91d1\u7532");
    }

    function item_4308() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 2, 2, 2000, 1, "\u6cf0\u5766\u6218\u7532");
    }

    function item_4309() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 3, 2, 3000, 1, "\u795e\u5947\u6218\u7532");
    }

    function item_4310() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 4, 2, 4000, 1, "\u79e9\u5e8f\u76d4\u7532");
    }

    function item_4311() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 5, 2, 5000, 1, "\u661f\u9668\u6218\u7532");
    }

    function item_4312() public pure returns (ItemAttribute memory) {
        return ItemAttribute(5, 5, 2, 15000, 1, "\u5723\u6bbf\u6218\u7532");
    }

    function item_4401() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 1, 2, 1000, 1, "\u62b5\u6297\u6597\u7bf7");
    }

    function item_4402() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 2, 2, 2000, 1, "\u5916\u4f7f\u5927\u6c05");
    }

    function item_4403() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 3, 2, 3000, 1, "\u6297\u9b54\u62ab\u98ce");
    }

    function item_4404() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 4, 2, 4000, 1, "\u6c34\u6676\u62ab\u98ce");
    }

    function item_4405() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 5, 2, 5000, 1, "\u9e70\u7fbd\u62ab\u98ce");
    }

    function item_4406() public pure returns (ItemAttribute memory) {
        return ItemAttribute(6, 5, 2, 15000, 1, "\u72ee\u9b03\u62ab\u98ce");
    }

    function item_4701() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 1, 2, 1000, 1, "\u52c7\u6c14\u6302\u4ef6");
    }

    function item_4702() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 2, 2, 2000, 1, "\u81ea\u7531\u6302\u4ef6");
    }

    function item_4703() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 3, 2, 3000, 1, "\u5149\u660e\u6302\u4ef6");
    }

    function item_4704() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 4, 2, 4000, 1, "\u9f99\u7259\u9879\u94fe");
    }

    function item_4705() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 5, 2, 5000, 1, "\u771f\u7406\u5fbd\u7ae0");
    }

    function item_4706() public pure returns (ItemAttribute memory) {
        return ItemAttribute(7, 5, 2, 15000, 1, "\u5929\u4f7f\u9879\u94fe");
    }

    function item_4001() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 1, 2, 1000, 1, "\u6c34\u6676\u6307\u73af");
    }

    function item_4002() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 2, 2, 2000, 1, "\u5b9d\u77f3\u6212\u6307");
    }

    function item_4003() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 3, 2, 3000, 1, "\u8d2a\u5a6a\u6307\u73af");
    }

    function item_4004() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u795d\u798f\u6307\u73af");
    }

    function item_4005() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 5, 2, 5000, 1, "\u5149\u660e\u6307\u73af");
    }

    function item_4006() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 5, 2, 15000, 1, "\u6d77\u5996\u4e4b\u773c");
    }

    function item_4007() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u6d3b\u529b\u4e4b\u6212");
    }

    function item_4008() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u707e\u7978\u4e4b\u6212");
    }

    function item_4009() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u8bc5\u5492\u6307\u73af");
    }

    function item_4010() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u9f99\u773c\u6212");
    }

    function item_4011() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 4, 2, 4000, 1, "\u9f99\u4e4b\u5fc3");
    }

    function item_4012() public pure returns (ItemAttribute memory) {
        return ItemAttribute(8, 5, 2, 15000, 1, "\u65e0\u754c\u4e4b\u4e66");
    }

    function item_8101() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 1, 3, 1000, 1, "\u9b54\u6cd5\u795e\u7bad");
    }

    function item_8102() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 1, 3, 1000, 1, "\u8fde\u73e0\u706b\u7403");
    }

    function item_8103() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 1, 3, 1000, 1, "\u9a71\u9b54\u5927\u6cd5");
    }

    function item_8104() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 1, 3, 1000, 1, "\u653b\u51fb\u52a0\u901f");
    }

    function item_8105() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 1, 3, 1000, 1, "\u5723\u7075\u4f50\u4f51");
    }

    function item_8106() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 2, 3, 2000, 1, "\u9739\u96f3\u95ea\u7535");
    }

    function item_8107() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 2, 3, 2000, 1, "\u9739\u96f3\u5bd2\u51b0");
    }

    function item_8108() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 2, 3, 2000, 1, "\u8fdf\u7f13\u5927\u6cd5");
    }

    function item_8109() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 2, 3, 2000, 1, "\u6297\u9b54\u5927\u6cd5");
    }

    function item_8110() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 2, 3, 2000, 1, "\u55dc\u8840\u5947\u672f");
    }

    function item_8111() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 3, 3, 3000, 1, "\u70c8\u706b\u9b54\u5899");
    }

    function item_8112() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 3, 3, 3000, 1, "\u57cb\u8bbe\u5730\u96f7");
    }

    function item_8113() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 3, 3, 3000, 1, "\u53cc\u76ee\u5931\u660e");
    }

    function item_8114() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 3, 3, 3000, 1, "\u6d41\u6c99\u9677\u9631");
    }

    function item_8115() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 3, 3, 3000, 1, "\u6b22\u6b23\u9f13\u821e");
    }

    function item_8116() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 4, 3, 4000, 1, "\u5730\u72f1\u70c8\u7130");
    }

    function item_8117() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 4, 3, 4000, 1, "\u4ea1\u7075\u6740\u624b");
    }

    function item_8118() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 4, 3, 4000, 1, "\u6d41\u661f\u706b\u96e8");
    }

    function item_8119() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 4, 3, 4000, 1, "\u5927\u529b\u795e\u76fe");
    }

    function item_8120() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 4, 3, 4000, 1, "\u767e\u53d1\u767e\u4e2d");
    }

    function item_8121() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 5, 3, 5000, 1, "\u672b\u65e5\u5ba1\u5224");
    }

    function item_8122() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 5, 3, 5000, 1, "\u5bd2\u51b0\u9b54\u73af");
    }

    function item_8123() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 5, 3, 5000, 1, "\u77ac\u95f4\u79fb\u52a8");
    }

    function item_8124() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 5, 3, 5000, 1, "\u7948\u7977");
    }

    function item_8125() public pure returns (ItemAttribute memory) {
        return ItemAttribute(9, 5, 3, 5000, 1, "\u6b21\u5143\u4e4b\u95e8");
    }

    function item_4801() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(9, 5, 3, 15000, 1, "\u706b\u7cfb\u9b54\u6cd5\u4e66");
    }

    function item_4802() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(
                9,
                5,
                3,
                15000,
                1,
                "\u7cbe\u795e\u7cfb\u9b54\u6cd5\u4e66"
            );
    }

    function item_4803() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(9, 5, 3, 15000, 1, "\u6c14\u7cfb\u9b54\u6cd5\u4e66");
    }

    function item_4804() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(9, 5, 3, 15000, 1, "\u6c34\u7cfb\u9b54\u6cd5\u4e66");
    }

    function item_4805() public pure returns (ItemAttribute memory) {
        return
            ItemAttribute(9, 5, 3, 15000, 1, "\u571f\u7cfb\u9b54\u6cd5\u4e66");
    }
}
