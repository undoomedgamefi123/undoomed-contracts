// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Hero} from "./hero.sol";
import {Item} from "./item.sol";
import {IERC20} from "./IERC20.sol";
import {UpgradeAttribute, HeroConfig} from "./hero_config.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

struct AdventureArmy {
    uint256 id;
    uint256 num;
}

contract Adventure is Initializable {
    address public contractCreator;
    address public wallet;
    IERC20 private usdt;
    IERC20 private croesus;
    IERC20 private crystal;
    Hero private he;
    Item private it;
    HeroConfig private hc;

    address[] public allowedUpdateAdventureAddresses;
    address[] public croesusMinters;
    address[] public rankingPublishers;
    uint256 private constant usdtDecimals = 6;
    uint256 private constant maxPoints = 1000000000;

    uint256 nextAdventure;
    mapping(uint256 => uint256) summoner;
    mapping(uint256 => uint256) crystalCount;
    mapping(uint256 => AdventureArmy[]) armys;
    // 1. 开始, 2. 结束
    mapping(uint256 => uint256) public status;
    mapping(uint256 => uint256) public startTimestamp;
    mapping(uint256 => uint256) public endTimestamp;
    mapping(uint256 => uint256) public points;
    mapping(uint256 => uint256) public summonerTotalPoints;
    mapping(uint256 => address) public adventureAddress;
    mapping(uint256 => uint256) public difficulty;
    mapping(uint256 => mapping(uint256 => uint256))
        public summonerDailyAdventureCount;

    mapping(uint256 => uint256) public dailyTotalAdventureCount;
    mapping(uint256 => uint256) public dailyTotalOutput;
    mapping(uint256 => uint256) public dailyTotalPoints;
    mapping(uint256 => bool) public dailyMinted;
    mapping(address => mapping(uint256 => uint256)) public ownerDailyPoints;
    mapping(address => mapping(uint256 => uint256)) public ownerWeeklyPoints;
    mapping(address => uint256[]) public ownerNotRecieveDays;

    struct RankingAward {
        address owner;
        uint256 points;
        uint256 usdtAward;
        uint256 updateTimestamp;
    }
    mapping(uint256 => RankingAward[20]) public dailyRankingList;
    mapping(uint256 => uint256) public dailyRankingUsdtAmount;
    mapping(address => uint256) public ownerRankingUsdtAward;
    mapping(uint256 => bool) public dailyRankingPublished;

    mapping(uint256 => RankingAward[20]) public weeklyRankingList;
    mapping(uint256 => uint256) public weeklyRankingUsdtAmount;
    mapping(uint256 => bool) public weeklyRankingPublished;

    mapping(uint256 => uint256) public summonerLastAdventure;
    mapping(uint256 => uint256) public wave;
    mapping(address => AwardCroesusRecordForSave[]) public awardCroesusHistory;
    mapping(address => uint256) public ownerWeeklyRankingUsdtAward;

    struct AdventureInfo {
        uint256 summoner;
        uint256 crystalCount;
        AdventureArmy[] armys;
        uint256 status;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 points;
        uint256 summonerTotalPoints;
        address adventureAddress;
        uint256 difficulty;
        uint256 adventureId;
    }

    event AdventureStart(
        address indexed owner,
        uint256 summoner,
        uint256 crystalCount,
        AdventureArmy[] armys,
        uint256 status,
        uint256 startTimestamp,
        uint256 difficulty,
        uint256 adventure
    );

    event AdventureEnd(
        address indexed owner,
        uint256 summoner,
        uint256 crystalCount,
        AdventureArmy[] armys,
        uint256 status,
        uint256 endTimestamp,
        uint256 difficulty,
        uint256 adventure,
        uint256 wave,
        uint256 points
    );

    event PointsCroesusRecieved(address indexed owner, uint256 amount);

    event RankingUsdtAwardRecieved(address indexed owner, uint256 amount);
    event DailyRankingPublished(uint256 timestampDay);
    event WeeklyRankingPublished(uint256 timestampWeek);
    event DailyCroesusMinted(uint256 timestampDay);

    function initialize(
        address _heAddr,
        address _crystalAddr,
        address _itAddr,
        address _usdtAddr,
        address _walletAddr,
        address _hcAddr,
        address _croesusAddr
    ) public initializer {
        nextAdventure = 1;
        he = Hero(_heAddr);
        crystal = IERC20(_crystalAddr);
        it = Item(_itAddr);
        usdt = IERC20(_usdtAddr);
        wallet = _walletAddr;
        hc = HeroConfig(_hcAddr);
        croesus = IERC20(_croesusAddr);
        contractCreator = msg.sender;
    }

    function updateWallet(address _address) external onlyOwner {
        require(_address != address(0), "Battle: None zero address.");
        wallet = _address;
    }

    struct SummonerTotalPoints {
        uint256 summoner;
        uint256 totalPoints;
    }

    function getSummonersTotalPoints(uint256[] memory _summoners)
        external
        view
        returns (SummonerTotalPoints[] memory)
    {
        require(
            _summoners.length <= 50,
            "Battle: Size of batch can not exceed 50."
        );
        SummonerTotalPoints[] memory list = new SummonerTotalPoints[](
            _summoners.length
        );
        for (uint256 index = 0; index < _summoners.length; index++) {
            uint256 _summoner = _summoners[index];
            list[index] = SummonerTotalPoints(
                _summoner,
                summonerTotalPoints[_summoner]
            );
        }
        return list;
    }

    function getAdventures(uint256[] memory _adventures)
        external
        view
        returns (AdventureInfo[] memory)
    {
        require(
            _adventures.length <= 50,
            "Battle: Size of batch can not exceed 50."
        );
        AdventureInfo[] memory list = new AdventureInfo[](_adventures.length);
        for (uint256 index = 0; index < _adventures.length; index++) {
            uint256 _adventure = _adventures[index];
            list[index] = AdventureInfo(
                summoner[_adventure],
                crystalCount[_adventure],
                armys[_adventure],
                status[_adventure],
                startTimestamp[_adventure],
                endTimestamp[_adventure],
                points[_adventure],
                summonerTotalPoints[_adventure],
                adventureAddress[_adventure],
                difficulty[_adventure],
                summonerLastAdventure[summoner[_adventure]]
            );
        }
        return list;
    }

    function getSummonersLastAdventure(uint256[] memory _summoners)
        external
        view
        returns (AdventureInfo[] memory)
    {
        require(
            _summoners.length <= 50,
            "Battle: Size of batch can not exceed 50."
        );
        AdventureInfo[] memory list = new AdventureInfo[](_summoners.length);
        for (uint256 index = 0; index < _summoners.length; index++) {
            uint256 _summoner = _summoners[index];
            uint256 _adventure = summonerLastAdventure[_summoner];
            list[index] = AdventureInfo(
                _summoner,
                crystalCount[_adventure],
                armys[_adventure],
                status[_adventure],
                startTimestamp[_adventure],
                endTimestamp[_adventure],
                points[_adventure],
                summonerTotalPoints[_adventure],
                adventureAddress[_adventure],
                difficulty[_adventure],
                _adventure
            );
        }
        return list;
    }

    function adventure(
        uint256 _summoner,
        uint256 _difficulty,
        uint256 _crystalCount,
        uint256 _carryCrystalCount,
        AdventureArmy[] memory _armys
    ) external {
        require(
            _isApprovedOrOwnerOfSummoner(_summoner),
            "Battle: Not the hero's owner."
        );
        require(
            !he.isWorking(_summoner),
            "Battle: Hero is staked or in the battle."
        );
        uint256 timestampDay = _getTimestampDay(block.timestamp);
        require(
            summonerDailyAdventureCount[_summoner][timestampDay] < 2,
            "Battle: Each hero can join two battles per day only."
        );
        require(
            _difficulty >= 1 && _difficulty <= 3,
            "Battle: The difficulty of battle is 1 to 3."
        );
        UpgradeAttribute memory heroAttr = hc.getUpgradeAttribute(
            he.level(_summoner)
        );
        bool[5] memory armyAppeared = [false, false, false, false, false];
        for (uint256 index = 0; index < _armys.length; index++) {
            uint256 _armyId = _armys[index].id;
            ArmyInfo memory _armyInfo = _armyLevelById(_armyId);
            require(
                _armyId <= 2005 && _armyId >= 2001,
                "Battle: Wrong troops ID."
            );
            require(
                heroAttr.armyLevel >= _armyInfo.level,
                "Battle: The level of troops exceeds the amount of hero's seal."
            );
            require(
                !armyAppeared[_armyInfo.level - 1],
                "Battle: Troops ID repeats."
            );
            armyAppeared[_armyInfo.level - 1] = true;
            _carryCrystalCount +=
                _armys[index].num *
                _armyInfo.recruitmentPrice;
        }
        require(
            _carryCrystalCount == _crystalCount,
            "Battle: Wrong number of crystals."
        );
        if (_crystalCount > 0) {
            crystal.transferFrom(msg.sender, wallet, _crystalCount * 1e18);
        }
        uint256 totalAmount = (_difficulty + 1) * 10**usdtDecimals;
        usdt.transferFrom(msg.sender, wallet, (totalAmount * 70) / 100);
        usdt.transferFrom(msg.sender, address(this), (totalAmount * 30) / 100);
        he.setAdventuring(_summoner, true);
        difficulty[nextAdventure] = _difficulty;
        adventureAddress[nextAdventure] = msg.sender;
        summoner[nextAdventure] = _summoner;
        crystalCount[nextAdventure] = _crystalCount;
        AdventureArmy[] storage sArmys = armys[nextAdventure];
        summonerLastAdventure[_summoner] = nextAdventure;
        for (uint256 index = 0; index < _armys.length; index++) {
            sArmys.push(_armys[index]);
        }
        status[nextAdventure] = 1;
        startTimestamp[nextAdventure] = block.timestamp;
        emit AdventureStart(
            msg.sender,
            _summoner,
            _crystalCount,
            _armys,
            status[nextAdventure],
            startTimestamp[nextAdventure],
            _difficulty,
            nextAdventure
        );
        nextAdventure++;
    }

    struct ArmyInfo {
        uint256 level;
        uint256 population;
        uint256 recruitmentPrice;
    }

    function _armyLevelById(uint256 _armyId)
        internal
        pure
        returns (ArmyInfo memory info)
    {
        if (_armyId == 2001) {
            info = ArmyInfo(1, 60, 40);
        } else if (_armyId == 2002) {
            info = ArmyInfo(2, 36, 90);
        } else if (_armyId == 2003) {
            info = ArmyInfo(3, 24, 150);
        } else if (_armyId == 2004) {
            info = ArmyInfo(4, 12, 250);
        } else if (_armyId == 2005) {
            info = ArmyInfo(5, 6, 500);
        }
    }

    function updateAdventureResult(
        uint256 _adventure,
        uint256 _points,
        uint256 _wave
    ) external {
        require(
            _isCallFromAllowedUpdateAdventureAddresses(),
            "Battle: Address not allowed."
        );
        require(_points <= maxPoints, "Battle: Wrong Reputation Point.");
        require(status[_adventure] == 1, "Battle: Abnormal battle status.");
        uint256 _summoner = summoner[_adventure];
        he.setAdventuring(_summoner, false);
        endTimestamp[_adventure] = block.timestamp;
        status[_adventure] = 2;
        points[_adventure] = _points;
        wave[_wave] = _wave;
        address _owner = adventureAddress[_adventure];
        uint256 timestampDay = _getTimestampDay(block.timestamp);
        dailyTotalAdventureCount[timestampDay]++;
        summonerDailyAdventureCount[_summoner][timestampDay]++;
        if (_points > 0) {
            summonerTotalPoints[summoner[_adventure]] += _points;
            dailyTotalPoints[timestampDay] += _points;
            ownerDailyPoints[_owner][timestampDay] += _points;
            _arryaPush(ownerNotRecieveDays[_owner], timestampDay);
        }
        _updateRankingList(_owner, _adventure, timestampDay, _points);
        if (_wave > 0) {
            _openItem(_owner, _summoner);
        }
        emit AdventureEnd(
            _owner,
            _summoner,
            crystalCount[_adventure],
            armys[_adventure],
            status[_adventure],
            block.timestamp,
            difficulty[_adventure],
            _adventure,
            _wave,
            _points
        );
    }

    function _openItem(address _owner, uint256 _summoner) private {
        uint256 _quality = he.quality(_summoner);
        //1/1000，1/700，1/500，1/300,1/100
        uint256 _randomCount = 1000;
        if (_quality == 5) {
            _randomCount = 100;
        } else if (_quality == 4) {
            _randomCount = 300;
        } else if (_quality == 3) {
            _randomCount = 500;
        } else if (_quality == 2) {
            _randomCount = 700;
        }
        it.openItemRandom(_owner, _randomCount);
    }

    function _updateRankingList(
        address _owner,
        uint256 _adventure,
        uint256 timestampDay,
        uint256 _points
    ) private {
        uint256 _difficulty = difficulty[_adventure];
        uint256 amount = (((_difficulty + 1) * 10**usdtDecimals) * 30) / 100;
        uint256 timestampWeek = _getTimestampWeek(timestampDay);
        weeklyRankingUsdtAmount[timestampWeek] += amount / 3;
        dailyRankingUsdtAmount[timestampDay] += (amount * 2) / 3;
        if (_points > 0) {
            uint256 _ownerDailyPoints = ownerDailyPoints[_owner][timestampDay];
            ownerWeeklyPoints[_owner][timestampWeek] += _points;
            RankingAward[20] memory _dailyRankingList = dailyRankingList[
                timestampDay
            ];
            uint256 minPoints = _dailyRankingList[0].points;
            uint256 minIndex = 0;
            uint256 ownerIndex = 20;
            for (uint256 i = 0; i < 20; i++) {
                RankingAward memory item = _dailyRankingList[i];
                if (item.points < minPoints) {
                    minPoints = item.points;
                    minIndex = i;
                } else if (item.points == minPoints) {
                    if (
                        _dailyRankingList[minIndex].updateTimestamp <
                        item.updateTimestamp
                    ) {
                        minPoints = item.points;
                        minIndex = i;
                    }
                }
                if (item.owner == _owner) {
                    ownerIndex = i;
                }
            }
            if (_ownerDailyPoints > minPoints) {
                if (ownerIndex < 20) {
                    minIndex = ownerIndex;
                }
                dailyRankingList[timestampDay][minIndex] = RankingAward(
                    _owner,
                    _ownerDailyPoints,
                    0,
                    block.timestamp
                );
            }
            RankingAward[20] memory _weeklyRankingList = weeklyRankingList[
                timestampWeek
            ];
            minPoints = _weeklyRankingList[0].points;
            minIndex = 0;
            ownerIndex = 20;
            for (uint256 i = 0; i < 20; i++) {
                RankingAward memory item = _weeklyRankingList[i];
                if (item.points < minPoints) {
                    minPoints = item.points;
                    minIndex = i;
                } else if (item.points == minPoints) {
                    if (
                        _dailyRankingList[minIndex].updateTimestamp <
                        item.updateTimestamp
                    ) {
                        minPoints = item.points;
                        minIndex = i;
                    }
                }
                if (item.owner == _owner) {
                    ownerIndex = i;
                }
            }
            uint256 _ownerWeeklyPoints = ownerWeeklyPoints[_owner][
                timestampWeek
            ];
            if (_ownerWeeklyPoints > minPoints) {
                if (ownerIndex < 20) {
                    minIndex = ownerIndex;
                }
                weeklyRankingList[timestampWeek][minIndex] = RankingAward(
                    _owner,
                    _ownerWeeklyPoints,
                    0,
                    block.timestamp
                );
            }
        }
    }

    function getDailyRankingList(uint256 _timestampDay)
        external
        view
        returns (RankingAward[20] memory)
    {
        return dailyRankingList[_timestampDay];
    }

    function getWeeklyRankingList(uint256 _timestampWeek)
        external
        view
        returns (RankingAward[20] memory)
    {
        return weeklyRankingList[_timestampWeek];
    }

    function publishDailyRanking(uint256 timestampDay) external {
        require(_isRankingPublisher(), "Battle: Address not available.");
        require(
            _getTimestampDay(block.timestamp) > timestampDay,
            "Battle: Wait for distribution time."
        );
        require(
            !dailyRankingPublished[timestampDay],
            "Battle: Disrtibuted Already."
        );
        dailyRankingPublished[timestampDay] = true;
        RankingAward[20] storage list = dailyRankingList[timestampDay];
        for (uint256 i = 0; i < 19; i++) {
            for (uint256 j = 0; j < 18 - i; j++) {
                if (list[j].points < list[j + 1].points) {
                    RankingAward memory temp = list[j + 1];
                    list[j + 1] = list[j];
                    list[j] = temp;
                } else if (list[j].points == list[j + 1].points) {
                    if (list[j].updateTimestamp > list[j + 1].updateTimestamp) {
                        RankingAward memory temp = list[j + 1];
                        list[j + 1] = list[j];
                        list[j] = temp;
                    }
                }
            }
        }
        uint256 amount = dailyRankingUsdtAmount[timestampDay];
        // 第1名：奖金50%
        // 第2-5名：平分奖金35%
        uint256 amount2 = (amount * 7) / 80;
        // 第6-10名：平分奖金10%
        uint256 amount3 = amount / 50;
        // 第10-20名：平分奖金5%
        uint256 amount4 = amount / 200;
        if (list[0].owner != address(0)) {
            ownerRankingUsdtAward[list[0].owner] += amount / 2;
            list[0].usdtAward = amount / 2;
        }
        for (uint256 i = 1; i < 5; i++) {
            if (list[i].owner != address(0)) {
                ownerRankingUsdtAward[list[i].owner] += amount2;
                list[i].usdtAward = amount2;
            }
        }
        for (uint256 i = 5; i < 10; i++) {
            if (list[i].owner != address(0)) {
                ownerRankingUsdtAward[list[i].owner] += amount3;
                list[i].usdtAward = amount3;
            }
        }
        for (uint256 i = 10; i < 20; i++) {
            if (list[i].owner != address(0)) {
                ownerRankingUsdtAward[list[i].owner] += amount4;
                list[i].usdtAward = amount4;
            }
        }
        emit DailyRankingPublished(timestampDay);
    }

    function publishWeeklyRanking(uint256 timestampWeek) external {
        require(_isRankingPublisher(), "Battle: Address not available.");
        require(
            _getTimestampWeek(_getTimestampDay(block.timestamp)) >
                timestampWeek,
            "Battle: Wait for distribution time."
        );
        require(
            !weeklyRankingPublished[timestampWeek],
            "Battle: Disrtibuted Already."
        );
        weeklyRankingPublished[timestampWeek] = true;
        RankingAward[20] storage list = weeklyRankingList[timestampWeek];
        for (uint256 i = 0; i < 19; i++) {
            for (uint256 j = 0; j < 18 - i; j++) {
                if (list[j].points < list[j + 1].points) {
                    RankingAward memory temp = list[j + 1];
                    list[j + 1] = list[j];
                    list[j] = temp;
                } else if (list[j].points == list[j + 1].points) {
                    if (list[j].updateTimestamp > list[j + 1].updateTimestamp) {
                        RankingAward memory temp = list[j + 1];
                        list[j + 1] = list[j];
                        list[j] = temp;
                    }
                }
            }
        }
        uint256 amount = weeklyRankingUsdtAmount[timestampWeek];
        // 第1名：奖金50%
        // 第2-5名：平分奖金35%
        uint256 amount2 = (amount * 7) / 80;
        // 第6-10名：平分奖金10%
        uint256 amount3 = amount / 50;
        // 第10-20名：平分奖金5%
        uint256 amount4 = amount / 200;
        if (list[0].owner != address(0)) {
            ownerWeeklyRankingUsdtAward[list[0].owner] += amount / 2;
            list[0].usdtAward = amount / 2;
        }
        for (uint256 i = 1; i < 5; i++) {
            if (list[i].owner != address(0)) {
                ownerWeeklyRankingUsdtAward[list[i].owner] += amount2;
                list[i].usdtAward = amount2;
            }
        }
        for (uint256 i = 5; i < 10; i++) {
            if (list[i].owner != address(0)) {
                ownerWeeklyRankingUsdtAward[list[i].owner] += amount3;
                list[i].usdtAward = amount3;
            }
        }
        for (uint256 i = 10; i < 20; i++) {
            if (list[i].owner != address(0)) {
                ownerWeeklyRankingUsdtAward[list[i].owner] += amount4;
                list[i].usdtAward = amount4;
            }
        }
        emit WeeklyRankingPublished(timestampWeek);
    }

    function recieveDailyRankingUsdtAward() external {
        uint256 amount = ownerRankingUsdtAward[msg.sender];
        require(amount > 0, "Battle: No reward to claim.");
        usdt.transfer(msg.sender, amount);
        ownerRankingUsdtAward[msg.sender] = 0;
        emit RankingUsdtAwardRecieved(msg.sender, amount);
    }

    function recieveWeeklyRankingUsdtAward() external {
        uint256 amount = ownerWeeklyRankingUsdtAward[msg.sender];
        require(amount > 0, "Battle: No reward to claim.");
        usdt.transfer(msg.sender, amount);
        ownerWeeklyRankingUsdtAward[msg.sender] = 0;
        emit RankingUsdtAwardRecieved(msg.sender, amount);
    }

    function _arryaPush(uint256[] storage array, uint256 element) private {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == element) {
                return;
            }
        }
        array.push(element);
    }

    struct AwardCroesus {
        uint256 amount;
        uint256 totalOutput;
        uint256 points;
        uint256 totalPoints;
        uint256 timestampDay;
        bool minted;
        uint256 totalAdventureCount;
    }

    struct AwardCroesusRecordForSave {
        uint256 amount;
        uint256 timestampDay;
        uint256 recieveTimestamp;
    }

    function queryAwardCroesus(address _owner)
        public
        view
        returns (uint256 totalAmount, AwardCroesus[] memory list)
    {
        uint256[] storage _ownerNotRecieveDays = ownerNotRecieveDays[_owner];
        list = new AwardCroesus[](_ownerNotRecieveDays.length);
        for (uint256 index = 0; index < _ownerNotRecieveDays.length; index++) {
            uint256 timestampDay = _ownerNotRecieveDays[index];
            uint256 output = dailyTotalOutput[timestampDay];
            uint256 totalPoints = dailyTotalPoints[timestampDay];
            uint256 ownerPoints = ownerDailyPoints[_owner][timestampDay];
            uint256 amount = 0;
            bool minted = dailyMinted[timestampDay];
            if (output > 0 && totalPoints > 0 && ownerPoints > 0 && minted) {
                amount = (ownerPoints * output) / totalPoints;
            }
            totalAmount += amount;
            list[index] = AwardCroesus(
                amount,
                output,
                ownerPoints,
                totalPoints,
                timestampDay,
                minted,
                dailyTotalAdventureCount[timestampDay]
            );
        }
    }

    struct AwardCroesusRecord {
        uint256 amount;
        uint256 totalOutput;
        uint256 points;
        uint256 totalPoints;
        uint256 timestampDay;
        uint256 recieveTimestamp;
    }

    function getAwardCroesusHistory(
        address _owner,
        uint256 page,
        uint256 size,
        bool desc
    )
        external
        view
        returns (
            bool hasNext,
            uint256 total,
            AwardCroesusRecord[] memory list
        )
    {
        AwardCroesusRecordForSave[] storage history = awardCroesusHistory[
            _owner
        ];
        if (size > 50) {
            size = 50;
        }
        total = history.length;
        PageInfo memory pageInfo = _calcPageInfo(total, page, size, desc);
        hasNext = pageInfo.hasNext;
        list = new AwardCroesusRecord[](pageInfo.currentPageSize);
        for (uint256 index = 0; index < pageInfo.currentPageSize; index++) {
            AwardCroesusRecordForSave memory record = desc
                ? history[pageInfo.start - index]
                : history[pageInfo.start + index];
            uint256 timestampDay = record.timestampDay;
            list[index] = AwardCroesusRecord(
                record.amount,
                dailyTotalOutput[timestampDay],
                ownerDailyPoints[_owner][timestampDay],
                dailyTotalPoints[timestampDay],
                timestampDay,
                record.recieveTimestamp
            );
        }
    }

    struct PageInfo {
        uint256 start;
        uint256 currentPageSize;
        bool hasNext;
    }

    function _calcPageInfo(
        uint256 total,
        uint256 page,
        uint256 size,
        bool desc
    ) private pure returns (PageInfo memory info) {
        bool hasNext = total > (page + 1) * size;
        uint256 currentPageSize = hasNext ? size : total - page * size;
        uint256 start = desc ? page * size + currentPageSize - 1 : page * size;
        info = PageInfo(start, currentPageSize, hasNext);
    }

    function recieveCroesus() external {
        uint256[] memory _ownerNotRecieveDays = ownerNotRecieveDays[msg.sender];
        uint256 totalAmount = 0;
        AwardCroesusRecordForSave[] storage history = awardCroesusHistory[
            msg.sender
        ];
        for (uint256 index = 0; index < _ownerNotRecieveDays.length; index++) {
            uint256 timestampDay = _ownerNotRecieveDays[index];
            if (!dailyMinted[timestampDay]) {
                continue;
            }
            uint256 output = dailyTotalOutput[timestampDay];
            uint256 totalPoints = dailyTotalPoints[timestampDay];
            uint256 ownerPoints = ownerDailyPoints[msg.sender][timestampDay];
            if (output > 0 && totalPoints > 0 && ownerPoints > 0) {
                uint256 amount = (ownerPoints * output) / totalPoints;
                totalAmount += amount;
                history.push(
                    AwardCroesusRecordForSave(
                        amount,
                        timestampDay,
                        block.timestamp
                    )
                );
            }
            _ownerNotRecieveDays[index] = 0;
        }
        if (totalAmount > 0) {
            croesus.transfer(msg.sender, totalAmount);
        }
        emit PointsCroesusRecieved(msg.sender, totalAmount);
        uint256 leftCount;
        for (uint256 index = 0; index < _ownerNotRecieveDays.length; index++) {
            if (_ownerNotRecieveDays[index] > 0) {
                leftCount++;
            }
        }
        uint256[] memory newArray = new uint256[](leftCount);
        uint256 newIndex;
        for (uint256 index = 0; index < _ownerNotRecieveDays.length; index++) {
            if (_ownerNotRecieveDays[index] > 0) {
                newArray[newIndex] = _ownerNotRecieveDays[index];
                newIndex++;
            }
        }
        ownerNotRecieveDays[msg.sender] = newArray;
    }

    function addCoresusMinter(address _address) external onlyOwner {
        croesusMinters.push(_address);
    }

    function updateItemAddress(address _itemAddr) external onlyOwner {
        it = Item(_itemAddr);
    }

    function removeCoresusMinter(address _address) external onlyOwner {
        require(_address != address(0), "Battle: None zero address.");
        _addressArrayDelete(croesusMinters, _address);
    }

    function addRankingPublisher(address _address) external onlyOwner {
        rankingPublishers.push(_address);
    }

    function removeRankingPublisher(address _address) external onlyOwner {
        require(_address != address(0), "Battle: None zero address.");
        _addressArrayDelete(rankingPublishers, _address);
    }

    function mintCroesus(uint256 timestampDay) external {
        require(_isCoresusMinter(), "Battle: Address not available.");
        require(
            _getTimestampDay(block.timestamp) > timestampDay,
            "Battle: Wait for distribution time."
        );
        require(!dailyMinted[timestampDay], "Battle: Disrtibuted Already.");
        uint256 x = dailyTotalAdventureCount[timestampDay];
        uint256 output = (((10000 * x) * 1e18) / (4500 + x));
        uint256 amount1 = (output * 9375) / 10000;
        uint256 amount2 = (output * 625) / 10000;
        croesus.mint(wallet, amount2);
        croesus.mint(address(this), amount1);
        dailyTotalOutput[timestampDay] = amount1;
        dailyMinted[timestampDay] = true;
        emit DailyCroesusMinted(timestampDay);
    }

    function _isCoresusMinter() private view returns (bool) {
        return
            croesusMinters.length > 0 &&
            _addressesContains(croesusMinters, msg.sender);
    }

    function _isRankingPublisher() private view returns (bool) {
        return
            rankingPublishers.length > 0 &&
            _addressesContains(rankingPublishers, msg.sender);
    }

    function addAllowedUpdateAdventureAddresses(address _address)
        external
        onlyOwner
    {
        allowedUpdateAdventureAddresses.push(_address);
    }

    function removeAllowedUpdateAdventureAddresses(address _address)
        external
        onlyOwner
    {
        require(_address != address(0), "Adventure: None zero address.");
        _addressArrayDelete(allowedUpdateAdventureAddresses, _address);
    }

    function _isCallFromAllowedUpdateAdventureAddresses()
        private
        view
        returns (bool)
    {
        return
            allowedUpdateAdventureAddresses.length > 0 &&
            _addressesContains(allowedUpdateAdventureAddresses, msg.sender);
    }

    function _isApprovedOrOwnerOfSummoner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            he.getApproved(_summoner) == msg.sender ||
            he.ownerOf(_summoner) == msg.sender;
    }

    function _arrayContains(uint256[] memory array, uint256 content)
        private
        pure
        returns (bool)
    {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == content) {
                return true;
            }
        }
        return false;
    }

    function _addressesContains(address[] memory array, address content)
        private
        pure
        returns (bool)
    {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == content) {
                return true;
            }
        }
        return false;
    }

    function _addressArrayDelete(address[] storage array, address content)
        internal
    {
        uint256 contentIndex = 0;
        bool find = false;
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == content) {
                contentIndex = index;
                find = true;
                break;
            }
        }
        if (find) {
            uint256 lastIndex = array.length - 1;
            if (contentIndex != lastIndex) {
                address lastContent = array[lastIndex];
                array[contentIndex] = lastContent;
            }
            array.pop();
        }
    }

    function _getTimestampDay(uint256 timestamp)
        public
        pure
        returns (uint256 _day)
    {
        _day = (timestamp + 12 hours) / 24 hours;
    }

    function _getTimestampWeek(uint256 timestampDay)
        public
        pure
        returns (uint256 _day)
    {
        _day = (timestampDay + 10) / 7;
    }

    modifier onlyOwner() {
        require(
            contractCreator == msg.sender,
            "Battle: caller is not the owner"
        );
        _;
    }
}
