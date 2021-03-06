// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {BuildingAttribute, BuildingConfig, BuildingFunctionType} from "./building_config.sol";
import {Hero} from "./hero.sol";
import {Item} from "./item.sol";
import {IERC20} from "./IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Building is Initializable {
    IERC20 private croesus;
    IERC20 private crystal;
    BuildingConfig private bc;
    Hero private he;

    struct EconomyRecord {
        uint256 buildingId;
        uint256 pledgeTimestamp;
        uint256 lastRecieveAwardTimestamp;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 award;
        uint256 currentTimestamp;
        uint256 pledgeCoinRuleChangeTimestamp;
        uint256 pledgeWeeks;
        uint256 pledgeCoins;
    }

    uint8 public decimals;
    uint256 constant DAY = 1 days;
    uint256 constant halfAwardDuration = 15;

    address public wallet;
    address public contractCreator;

    mapping(address => mapping(uint256 => bool)) public ownedBuildings;
    mapping(address => uint256) public buildingCount;
    // account buildingId summonerId
    mapping(address => mapping(uint256 => uint256[])) public pledgeIds;

    // summoner pledge timestamp
    mapping(uint256 => uint256) public summonerPledgeTimestamp;
    mapping(uint256 => uint256) public summonerPledgeBuildingId;
    mapping(uint256 => uint256) public summonerLastRecieveAwardTimestamp;
    mapping(uint256 => uint256) public summonerLastCountTimestamp;
    mapping(uint256 => uint256) public summonerLastCountAward;

    // owner buildingId count
    mapping(address => mapping(uint256 => uint256))
        public pledgeCoinRuleChangeTimestamp;
    mapping(address => mapping(uint256 => uint256)) public pledgeWeeks;
    mapping(address => mapping(uint256 => uint256)) public pledgeCoins;
    uint256 public totoalPledgedCroesus;

    event BuildingCreated(address indexed owner, uint256 buildingId);
    event PledgeCoinRuleChanged(
        address indexed owner,
        uint256 buildingId,
        uint256 weekNum,
        uint256 coins,
        uint256 changeTimestamp,
        BuildingFunctionType buildingType,
        uint256 armyStorageLimit,
        uint256 armyProduceRate
    );
    event CrystalReceived(
        address indexed owner,
        uint256 award,
        uint256 buildingId
    );
    event CoinRedeemed(
        address indexed owner,
        uint256 buildingId,
        uint256 coins,
        uint256 leftCoins
    );
    event HeroPledged(
        address indexed owner,
        uint256 summoner,
        uint256 buildingId,
        uint256 pledgeTimestamp
    );
    event HeroRedeemed(
        address indexed owner,
        uint256 summoner,
        uint256 buildingId
    );
    event CrystalMuiltReceived(address indexed owner, uint256 award);

    function initialize(
        address _bcAddr,
        address _he,
        address _croesusAddr,
        address _crystalAddr,
        address _walletAddr
    ) public initializer {
        decimals = 18;
        bc = BuildingConfig(_bcAddr);
        he = Hero(_he);
        croesus = IERC20(_croesusAddr);
        crystal = IERC20(_crystalAddr);
        wallet = _walletAddr;
        contractCreator = msg.sender;
    }

    struct BuildingPledgeInfo {
        address owner;
        uint256 buildingId;
        uint256 pledgeCoins;
        uint256 pledgeWeeks;
        uint256 pledgeCoinRuleChangeTimestamp;
        uint256[] pledgeHeros;
    }

    function getPledgeInfo(address _owner)
        external
        view
        returns (BuildingPledgeInfo[] memory)
    {
        uint256[] memory _buildingIds = getOwnedBuildings(_owner);
        BuildingPledgeInfo[] memory list = new BuildingPledgeInfo[](
            _buildingIds.length
        );
        for (uint256 index = 0; index < _buildingIds.length; index++) {
            uint256 _buildingId = _buildingIds[index];
            list[index] = BuildingPledgeInfo(
                _owner,
                _buildingId,
                pledgeCoins[_owner][_buildingId],
                pledgeWeeks[_owner][_buildingId],
                pledgeCoinRuleChangeTimestamp[_owner][_buildingId],
                pledgeIds[_owner][_buildingId]
            );
        }
        return list;
    }

    function updateBuildingConfigAddress(address _address) external onlyOwner {
        bc = BuildingConfig(_address);
    }

    function updateWallet(address _address) external onlyOwner {
        require(_address != address(0), "Building: None zero address.");
        wallet = _address;
    }

    function init() external {
        uint256[10] memory ids = bc.getInitialBuildingIds();
        for (uint256 index = 0; index < ids.length; index++) {
            ownedBuildings[msg.sender][ids[index]] = true;
            buildingCount[msg.sender] += 1;
        }
    }

    function create(uint256 buildingId) external {
        uint256[16] memory _array = bc.getAllBuildingIds();
        uint256[] memory array = new uint256[](_array.length);
        for (uint256 index = 0; index < _array.length; index++) {
            array[index] = _array[index];
        }
        require(
            _arrayContains(array, buildingId),
            "Building: Unknown Building ID."
        );
        mapping(uint256 => bool) storage senderBuildings = ownedBuildings[
            msg.sender
        ];
        require(
            senderBuildings[buildingId - 1],
            "Building: Buildings must be created in order."
        );
        require(
            !senderBuildings[buildingId],
            "Building: Already owned building."
        );

        BuildingAttribute memory attr = bc.buildingById(buildingId);
        if (attr.createCrystalCost > 0) {
            crystal.transferFrom(
                msg.sender,
                wallet,
                attr.createCrystalCost * 1e18
            );
        }
        if (attr.createCroesusCost > 0) {
            _consumeCroesus(msg.sender, attr.createCroesusCost * 1e18);
        }
        senderBuildings[buildingId] = true;
        buildingCount[msg.sender] += 1;
        emit BuildingCreated(msg.sender, buildingId);
    }

    function _consumeCroesus(address sender, uint256 amount) private {
        // ???1????????????20%???????????????????????????
        croesus.transferFrom(sender, address(0), (amount * 20) / 100);
        croesus.transferFrom(sender, wallet, (amount * 80) / 100);
    }

    function getArmyBuildingProduceRateAndStorageLimit(
        address _owner,
        uint256 _buildingId
    ) external view returns (uint256 storageLimit, uint256 produceRate) {
        (
            storageLimit,
            produceRate
        ) = _calcArmyBuildingProduceRateAndStorageLimit(
            pledgeWeeks[_owner][_buildingId],
            pledgeCoins[_owner][_buildingId],
            bc.buildingById(_buildingId),
            pledgeCoinRuleChangeTimestamp[_owner][_buildingId]
        );
    }

    function _calcArmyBuildingProduceRateAndStorageLimit(
        uint256 _weeks,
        uint256 _coins,
        BuildingAttribute memory attr,
        uint256 _timestamp
    ) private view returns (uint256 limit, uint256 rate) {
        if (_timestamp < block.timestamp - 12 weeks) {
            return (attr.population, attr.baseRate * 1e6);
        }
        uint256 tmp = 1e10 + (_weeks * _coins * 1e10) / (attr.pledgeLimit * 24);
        limit = (attr.population * tmp) / 1e10;
        rate = (attr.baseRate * tmp) / 1e4;
    }

    function redeemCoin(uint256 _buildingId, uint256 _coins) public {
        require(
            ownedBuildings[msg.sender][_buildingId],
            "Building: Unknown building."
        );
        uint256 lastTimestamp = pledgeCoinRuleChangeTimestamp[msg.sender][
            _buildingId
        ];
        require(
            lastTimestamp > 0,
            "Building: This amount of COSS is not locked yet."
        );
        uint256 weekFromNow = (block.timestamp - lastTimestamp) / DAY / 7;
        uint256 lastWeeks = pledgeWeeks[msg.sender][_buildingId];
        bool isTimeout = weekFromNow >= lastWeeks;
        require(isTimeout, "Building: Unexpired.");
        uint256 lastCoins = pledgeCoins[msg.sender][_buildingId];
        require(
            lastCoins >= _coins,
            "Building: This amount of COSS is not locked yet."
        );
        BuildingAttribute memory buildingAttr = bc.buildingById(_buildingId);
        _calculateCurrentAward(_buildingId, buildingAttr);
        croesus.transferFrom(wallet, msg.sender, _coins * 1e18);
        if (totoalPledgedCroesus >= _coins * 1e18) {
            totoalPledgedCroesus -= _coins * 1e18;
        }
        uint256 leftCoins = lastCoins - _coins;
        pledgeCoins[msg.sender][_buildingId] = leftCoins;
        if (leftCoins == 0) {
            pledgeCoinRuleChangeTimestamp[msg.sender][_buildingId] = 0;
            pledgeWeeks[msg.sender][_buildingId] = 0;
        }
        uint256 armyStorageLimit;
        uint256 armyProduceRate;
        if (buildingAttr.functionType == BuildingFunctionType.Army) {
            (
                armyStorageLimit,
                armyProduceRate
            ) = _calcArmyBuildingProduceRateAndStorageLimit(
                pledgeWeeks[msg.sender][_buildingId],
                leftCoins,
                buildingAttr,
                block.timestamp
            );
        }
        emit CoinRedeemed(msg.sender, _buildingId, _coins, leftCoins);
        emit PledgeCoinRuleChanged(
            msg.sender,
            _buildingId,
            pledgeWeeks[msg.sender][_buildingId],
            _coins,
            block.timestamp,
            buildingAttr.functionType,
            armyStorageLimit,
            armyProduceRate
        );
    }

    function multiRedeemCoin(
        uint256[] memory _buildingIds,
        uint256[] memory _multiCoins
    ) external {
        for (uint256 index = 0; index < _buildingIds.length; index++) {
            uint256 _buildingId = _buildingIds[index];
            uint256 _coins = _multiCoins[index];
            redeemCoin(_buildingId, _coins);
        }
    }

    function multiReceiveCrystal(uint256[] memory _buildingIds) external {
        uint256 totalAmount;
        for (uint256 index = 0; index < _buildingIds.length; index++) {
            uint256 _buildingId = _buildingIds[index];
            totalAmount += _prepareRecieveCrystal(_buildingId);
        }
        if (totalAmount > 0) {
            crystal.mint(msg.sender, totalAmount);
        }
        emit CrystalMuiltReceived(msg.sender, totalAmount);
    }

    function _prepareRecieveCrystal(uint256 _buildingId)
        private
        returns (uint256 amount)
    {
        require(
            ownedBuildings[msg.sender][_buildingId],
            "Building: Unknown building."
        );
        BuildingAttribute memory buildingAttr = bc.buildingById(_buildingId);
        require(
            buildingAttr.functionType == BuildingFunctionType.Economy,
            "Building: Not an Economical Building."
        );
        uint256[] storage pledgeSummoners = pledgeIds[tx.origin][_buildingId];
        for (uint256 index = 0; index < pledgeSummoners.length; index++) {
            uint256 _summoner = pledgeSummoners[index];
            uint256 currentAward = getCurrentAward(_summoner);
            amount += currentAward;
            summonerLastCountAward[_summoner] = 0;
            summonerLastCountTimestamp[_summoner] = block.timestamp;
        }
    }

    function changePledgeCoin(
        uint256 _buildingId,
        uint256 _weeks,
        uint256 _coins
    ) public {
        require(
            ownedBuildings[msg.sender][_buildingId],
            "Building: Unknown building."
        );
        require(
            _weeks <= 24 && _weeks > 0,
            "Building: Lock period is between 1 and 24 weeks."
        );
        uint256 lastTimestamp = pledgeCoinRuleChangeTimestamp[msg.sender][
            _buildingId
        ];
        uint256 weekFromNow = (block.timestamp - lastTimestamp) / DAY / 7;
        uint256 lastWeeks = pledgeWeeks[msg.sender][_buildingId];
        bool isTimeout = weekFromNow >= lastWeeks;
        uint256 lastCoins = pledgeCoins[msg.sender][_buildingId];
        if (!isTimeout) {
            require(
                lastWeeks < _weeks || lastCoins < _coins,
                "Building: Increasing time or amount is allowed."
            );
        }
        BuildingAttribute memory buildingAttr = bc.buildingById(_buildingId);
        require(
            buildingAttr.pledgeLimit >= _coins,
            "Building: Amount of locked COSS exceeds building limit."
        );
        int256 amount = int256(_coins) - int256(lastCoins);
        if (amount > 0) {
            croesus.transferFrom(msg.sender, wallet, uint256(amount) * 1e18);
            totoalPledgedCroesus += uint256(amount) * 1e18;
        } else if (amount != 0) {
            croesus.transferFrom(wallet, msg.sender, uint256(-amount) * 1e18);
            if (totoalPledgedCroesus >= _coins * 1e18) {
                totoalPledgedCroesus -= uint256(-amount) * 1e18;
            }
        }
        _calculateCurrentAward(_buildingId, buildingAttr);
        pledgeCoinRuleChangeTimestamp[msg.sender][_buildingId] = block
            .timestamp;
        pledgeWeeks[msg.sender][_buildingId] = _weeks;
        pledgeCoins[msg.sender][_buildingId] = _coins;
        uint256 armyStorageLimit;
        uint256 armyProduceRate;
        if (buildingAttr.functionType == BuildingFunctionType.Army) {
            (
                armyStorageLimit,
                armyProduceRate
            ) = _calcArmyBuildingProduceRateAndStorageLimit(
                _weeks,
                _coins,
                buildingAttr,
                block.timestamp
            );
        }
        emit PledgeCoinRuleChanged(
            msg.sender,
            _buildingId,
            _weeks,
            _coins,
            block.timestamp,
            buildingAttr.functionType,
            armyStorageLimit,
            armyProduceRate
        );
    }

    function multiChangePledgeCoin(
        uint256[] memory _buildingIds,
        uint256[] memory _multiWeeks,
        uint256[] memory _multiCoins
    ) external {
        for (uint256 index = 0; index < _buildingIds.length; index++) {
            uint256 _buildingId = _buildingIds[index];
            uint256 _weeks = _multiWeeks[index];
            uint256 _coins = _multiCoins[index];
            changePledgeCoin(_buildingId, _weeks, _coins);
        }
    }

    function _calculateCurrentAward(
        uint256 _buildingId,
        BuildingAttribute memory buildingAttr
    ) internal {
        if (buildingAttr.functionType == BuildingFunctionType.Economy) {
            uint256[] storage pledgeSummoners = pledgeIds[tx.origin][
                _buildingId
            ];
            for (uint256 index = 0; index < pledgeSummoners.length; index++) {
                uint256 _summoner = pledgeSummoners[index];
                uint256 currentAward = getCurrentAward(_summoner);
                summonerLastCountAward[_summoner] = currentAward;
                summonerLastCountTimestamp[_summoner] = block.timestamp;
            }
        }
    }

    struct SummonerCrystalAward {
        uint256 summoner;
        uint256 award;
    }

    function getCurrentAwards(uint256[] memory _summoners)
        public
        view
        returns (SummonerCrystalAward[] memory)
    {
        require(
            _summoners.length <= 50,
            "Building: Size of batch can not exceed 50."
        );
        SummonerCrystalAward[] memory awards = new SummonerCrystalAward[](
            _summoners.length
        );
        for (uint256 index = 0; index < _summoners.length; index++) {
            uint256 _summoner = _summoners[index];
            awards[index] = SummonerCrystalAward(
                _summoner,
                getCurrentAward(_summoner)
            );
        }
        return awards;
    }

    function getCurrentAward(uint256 _summoner)
        public
        view
        returns (uint256 count)
    {
        uint256 baseRate = _calculateAwardBaseRate(_summoner);
        count = summonerLastCountAward[_summoner];
        uint256 lastRevieveTimestamp = summonerLastRecieveAwardTimestamp[
            _summoner
        ];
        uint256 lastCountTimestamp = summonerLastCountTimestamp[_summoner];
        uint256 leftDuration = block.timestamp - lastCountTimestamp;
        uint256 firstSectionDuration = halfAwardDuration *
            DAY -
            ((lastCountTimestamp - lastRevieveTimestamp) %
                (halfAwardDuration * DAY));
        uint256 dayRate = (lastCountTimestamp - lastRevieveTimestamp) /
            DAY /
            halfAwardDuration;
        if (leftDuration > firstSectionDuration) {
            //???????????? q=1/2
            uint256 lastSection = (leftDuration - firstSectionDuration) %
                (halfAwardDuration * DAY);
            uint256 middleN = (leftDuration -
                firstSectionDuration -
                lastSection) / (halfAwardDuration * DAY);
            uint256 a1 = (baseRate * (halfAwardDuration * DAY)) /
                2**(dayRate + 1) /
                DAY;
            uint256 rate = 2**middleN;
            uint256 middleSn = (2 * a1 * (rate - 1)) / rate;
            count += (baseRate * firstSectionDuration) / 2**dayRate / DAY;
            count += middleSn;
            count +=
                (baseRate * lastSection) /
                2**(dayRate + middleN + 1) /
                DAY;
        } else {
            count += (baseRate * leftDuration) / 2**dayRate / DAY;
        }
    }

    function _calculateAwardBaseRate(uint256 _summoner)
        internal
        view
        returns (uint256)
    {
        uint256 _buildingId = summonerPledgeBuildingId[_summoner];
        if (_buildingId == 0) {
            return 0;
        }
        BuildingAttribute memory economyAttr = bc.buildingById(_buildingId);
        uint256 baseAward = economyAttr.baseRate;
        uint8 halfDecimals = decimals / 2;
        uint256 pledgeRatePart = _getPledgeRate(_buildingId) + 10**halfDecimals;
        uint256 levelPart = (he.level(_summoner) - 1) * 10**(halfDecimals - 1);
        uint256 _class = he.occupation(_summoner);
        uint256 heroAttr;
        if (_class == 1) {
            heroAttr = he.atkValue(_summoner);
        } else if (_class == 2) {
            heroAttr = he.magicValue(_summoner);
        } else if (_class == 3) {
            heroAttr = he.atkSpeed(_summoner);
        }
        uint256 attrPart = heroAttr * 3 * 10**(halfDecimals - 3);
        return
            baseAward *
            (10**halfDecimals + levelPart + attrPart) *
            pledgeRatePart;
    }

    function _getPledgeRate(uint256 _buildingId)
        internal
        view
        returns (uint256 rate)
    {
        uint256 _weeks = pledgeWeeks[tx.origin][_buildingId];
        uint256 _coins = pledgeCoins[tx.origin][_buildingId];
        return (_weeks * _coins * 10**(decimals / 2)) / (5000 * 24);
    }

    function pledgeHero(uint256 _buildingId, uint256 _summoner) public {
        require(
            ownedBuildings[tx.origin][_buildingId],
            "Building: Unknown building."
        );
        require(
            !he.isWorking(_summoner),
            "Building: Hero is staked or in the battle."
        );
        uint256[] storage pledgedSummoners = pledgeIds[tx.origin][_buildingId];
        BuildingAttribute memory buildingAttr = bc.buildingById(_buildingId);
        require(
            buildingAttr.functionType == BuildingFunctionType.Economy,
            "Building: Not an Economical Building."
        );
        require(
            uint256(buildingAttr.population) > pledgedSummoners.length,
            "Building: Building capacity limit reaches."
        );
        require(
            _isApprovedOrOwnerOfSummoner(_summoner),
            "Building: Not the hero's owner."
        );
        require(
            he.level(_summoner) >= buildingAttr.pledgeLevel,
            "Building: Hero's level less than required."
        );
        require(
            he.quality(_summoner) >= buildingAttr.pledgeQuality,
            "Building: Hero's rarity lower than required."
        );
        pledgedSummoners.push(_summoner);
        summonerPledgeTimestamp[_summoner] = block.timestamp;
        summonerPledgeBuildingId[_summoner] = _buildingId;
        summonerLastRecieveAwardTimestamp[_summoner] = block.timestamp;
        summonerLastCountTimestamp[_summoner] = block.timestamp;
        summonerLastCountAward[_summoner] = 0;
        he.setPledged(_summoner, true);
        emit HeroPledged(msg.sender, _summoner, _buildingId, block.timestamp);
    }

    function multiPledgeHero(
        uint256[] memory _buildingIds,
        uint256[][] memory _summoners
    ) external {
        for (uint256 index = 0; index < _buildingIds.length; index++) {
            uint256[] memory tmpSummoners = _summoners[index];
            uint256 _buildingId = _buildingIds[index];
            for (uint256 j = 0; j < tmpSummoners.length; j++) {
                uint256 _summoner = tmpSummoners[j];
                pledgeHero(_buildingId, _summoner);
            }
        }
    }

    function redeemHero(uint256 _summoner) public {
        require(
            he.isPledged(_summoner),
            "Building: The hero is not in staked status."
        );
        require(
            _isApprovedOrOwnerOfSummoner(_summoner),
            "Building: Not the hero's owner."
        );
        uint256 currentAward = getCurrentAward(_summoner);
        if (currentAward > 0) {
            crystal.mint(tx.origin, currentAward);
        }
        uint256 _buildingId = summonerPledgeBuildingId[_summoner];
        uint256[] storage pledgedSummoners = pledgeIds[tx.origin][_buildingId];
        _arrayDelete(pledgedSummoners, _summoner);
        summonerPledgeTimestamp[_summoner] = 0;
        summonerPledgeBuildingId[_summoner] = 0;
        summonerLastRecieveAwardTimestamp[_summoner] = 0;
        summonerLastCountTimestamp[_summoner] = 0;
        he.setPledged(_summoner, false);
        emit HeroRedeemed(msg.sender, _summoner, _buildingId);
        emit CrystalReceived(msg.sender, currentAward, _buildingId);
    }

    function multiRedeemHero(uint256[] memory _summoners) external {
        for (uint256 index = 0; index < _summoners.length; index++) {
            uint256 _summoner = _summoners[index];
            redeemHero(_summoner);
        }
    }

    function getOwnedBuildings(address _owner)
        public
        view
        returns (uint256[] memory buildings)
    {
        mapping(uint256 => bool) storage senderBuildings = ownedBuildings[
            _owner
        ];
        buildings = new uint256[](buildingCount[_owner]);
        uint256[16] memory ids = bc.getAllBuildingIds();
        uint256 length = 0;
        for (uint256 index = 0; index < ids.length; index++) {
            uint256 id = ids[index];
            if (senderBuildings[id]) {
                buildings[length] = id;
                length += 1;
            }
        }
    }

    function getOwnedBuildingCount() external view returns (uint256) {
        return buildingCount[msg.sender];
    }

    struct BuildingPledgeSummoners {
        address owner;
        uint256 buildingId;
        uint256[] summoners;
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

    function _arrayDelete(uint256[] storage array, uint256 content) internal {
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
                uint256 lastContent = array[lastIndex];
                array[contentIndex] = lastContent;
            }
            array.pop();
        }
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

    modifier onlyOwner() {
        require(
            contractCreator == msg.sender,
            "Building: Caller is not the owner."
        );
        _;
    }
}
