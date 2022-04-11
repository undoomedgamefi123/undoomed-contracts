// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ERC721Enumerable} from "./erc721.sol";
import {PubConfig, HeroInfo, UpgradeAttribute, HeroConfig, AbilityScore} from "./hero_config.sol";
import {IERC20} from "./IERC20.sol";
import {Item} from "./item.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Hero is ERC721Enumerable, Initializable {
    IERC20 private croesus;
    IERC20 private crystal;
    IERC20 private usdt;
    IERC20 private coupon;
    HeroConfig private hc;

    address public wallet;
    address public contractCreator;
    address[] public allowedPledgeFromAddresses;
    address[] public allowedUpdateAdventuringAddresses;

    uint256 public next_summoner;
    string public constant name = "Undoomed-Hero";
    string public constant symbol = "UDH";
    uint256 constant usdtDecimals = 6;

    mapping(uint256 => string) public heroName;
    mapping(uint256 => uint256) public quality;
    mapping(uint256 => uint256) public occupation;
    mapping(uint256 => uint256) public level;
    mapping(uint256 => uint256) public model;
    mapping(uint256 => uint256) public heroId;
    mapping(uint256 => uint256) public atkValue;
    mapping(uint256 => uint256) public atkSpeed;
    mapping(uint256 => uint256) public magicValue;
    mapping(uint256 => bool) public isPledged;
    mapping(uint256 => bool) public isAdventuring;
    Item private it;
    uint256 private _seed;

    event summoned(
        address indexed owner,
        uint256 summoner,
        string heroName,
        uint256 level,
        uint256 quality,
        uint256 occupation,
        uint256 atkValue,
        uint256 atkSpeed,
        uint256 magicValue,
        uint256 heroId,
        uint256 model
    );
    event leveled(address indexed owner, uint256 level, uint256 summoner);
    event levelFailed(address indexed owner, uint256 level, uint256 summoner);
    event SummonerRecycled(address indexed owner, uint256 summoner);
    event SummonersNameChanged(
        uint256 summoner,
        string oldName,
        string newName,
        address owner
    );

    function initialize(
        address _hcAddr,
        address _crystalAddr,
        address _croesusAddr,
        address _wallet,
        address _usdtAddr,
        address _couponAddr
    ) public initializer {
        next_summoner = 1;
        hc = HeroConfig(_hcAddr);
        contractCreator = msg.sender;
        crystal = IERC20(_crystalAddr);
        croesus = IERC20(_croesusAddr);
        usdt = IERC20(_usdtAddr);
        coupon = IERC20(_couponAddr);
        wallet = _wallet;
    }

    function mergeSummoners(uint256[5] memory _summoners, string memory _name)
        external
    {
        crystal.transferFrom(msg.sender, wallet, 2000 * 1e18);
        _consumeCroesus(msg.sender, 20 * 1e18);
        uint256 _level = 1;
        uint256 _occupation = occupation[_summoners[0]];
        uint256 _quality = quality[_summoners[0]];
        require(_quality < 5, "Hero: The greatest rarity is Legendary.");
        for (uint256 index = 0; index < _summoners.length; index++) {
            uint256 _summoner = _summoners[index];
            require(
                _isApprovedOrOwner(msg.sender, _summoner),
                "Hero: Not the hero's owner."
            );
            require(
                !isWorking(_summoner),
                "Hero: Hero is staked or in the battle."
            );
            if (_level < level[_summoner]) {
                _level = level[_summoner];
            }
            require(
                _occupation == occupation[_summoner],
                "Hero: Heroes have different classes."
            );
            require(
                _quality == quality[_summoner],
                "Hero: Heroes have different rarities."
            );
            _burn(_summoner);
        }
        uint256 _model = 1;
        uint16 modelRandom = uint16(_random(10000));
        if (modelRandom < 3333) {
            _model = 1;
        } else if (modelRandom >= 3333 && modelRandom < 6666) {
            _model = 2;
        } else {
            _model = 3;
        }
        _summon(
            SummonInfo(
                msg.sender,
                _quality + 1,
                _occupation,
                _model,
                _name,
                _level
            )
        );
    }

    function setSummonerName(uint256 _summoner, string memory _name) external {
        require(
            _isApprovedOrOwner(msg.sender, _summoner),
            "Hero: Not the hero's owner."
        );
        crystal.transferFrom(msg.sender, wallet, 1000 * 1e18);
        emit SummonersNameChanged(
            _summoner,
            heroName[_summoner],
            _name,
            ownerOf(_summoner)
        );
        heroName[_summoner] = _name;
    }

    function recycle(uint256 _summoner) external {
        require(
            _isApprovedOrOwner(msg.sender, _summoner),
            "Hero: Not the hero's owner."
        );
        require(
            !isWorking(_summoner),
            "Hero: Hero is staked or in the battle."
        );
        uint256 _level = level[_summoner];
        UpgradeAttribute memory _upgrade_attribute = hc.getUpgradeAttribute(
            _level
        );
        uint256 recoveryPay = _upgrade_attribute.recoveryPay * 1e18;
        _burn(_summoner);
        crystal.mint(msg.sender, recoveryPay);
        emit SummonerRecycled(msg.sender, _summoner);
    }

    function isWorking(uint256 _summoner) public view returns (bool) {
        return isPledged[_summoner] || isAdventuring[_summoner];
    }

    function level_up(uint256 _summoner) external {
        require(
            _isApprovedOrOwner(msg.sender, _summoner),
            "Hero: Not the hero's owner."
        );
        require(
            !isWorking(_summoner),
            "Hero: Hero is staked or in the battle."
        );
        uint256 _level = level[_summoner];
        require(_level < 8, "Hero: Higheist level is 8.");
        UpgradeAttribute memory _upgrade_attribute = hc.getUpgradeAttribute(
            _level
        );
        uint256 amount = _upgrade_attribute.upCost * 1e18;
        if (amount > 0) {
            crystal.transferFrom(msg.sender, wallet, amount);
        }
        amount = _upgrade_attribute.upCost2 * 1e18;
        if (amount > 0) {
            _consumeCroesus(msg.sender, amount);
        }
        level[_summoner] = _level + 1;
        emit leveled(msg.sender, level[_summoner], _summoner);
    }

    function _consumeCroesus(address sender, uint256 amount) private {
        // （1）销毁：20%自动进入销毁地址；
        croesus.transferFrom(sender, address(0), (amount * 20) / 100);
        croesus.transferFrom(sender, wallet, (amount * 80) / 100);
    }

    function summoners(uint256[] memory _summoners)
        external
        view
        returns (HeroInfo[] memory)
    {
        require(
            _summoners.length <= 50,
            "Hero: Size of batch can not exceed 50."
        );
        HeroInfo[] memory list = new HeroInfo[](_summoners.length);
        for (uint256 i = 0; i < _summoners.length; i++) {
            uint256 _summoner = _summoners[i];
            list[i] = HeroInfo(
                heroName[_summoner],
                level[_summoner],
                quality[_summoner],
                occupation[_summoner],
                atkValue[_summoner],
                atkSpeed[_summoner],
                magicValue[_summoner],
                isPledged[_summoner],
                isAdventuring[_summoner],
                _summoner,
                heroId[_summoner],
                model[_summoner]
            );
        }
        return list;
    }

    function abilityScores(uint256 _summoner)
        external
        view
        returns (AbilityScore memory)
    {
        return
            AbilityScore(
                atkValue[_summoner],
                atkSpeed[_summoner],
                magicValue[_summoner]
            );
    }

    function summon(string memory _name) external {
        //25 usdt
        usdt.transferFrom(msg.sender, wallet, 30 * 10**usdtDecimals);
        _summonRoll(msg.sender, _name);
    }

    function summonByCoupon(string memory _name) external {
        coupon.transferFrom(msg.sender, address(this), 1);
        _summonRoll(msg.sender, _name);
    }

    function _summonRoll(address _owner, string memory _name) private {
        (uint256 _quality, uint256 _occupation, uint256 _model) = _roll();
        _summon(SummonInfo(_owner, _quality, _occupation, _model, _name, 1));
    }

    struct SummonInfo {
        address owner;
        uint256 quality;
        uint256 occupation;
        uint256 model;
        string name;
        uint256 level;
    }

    function _summon(SummonInfo memory info) private {
        _safeMint(info.owner, next_summoner);
        occupation[next_summoner] = info.occupation;
        level[next_summoner] = info.level;
        quality[next_summoner] = info.quality;
        model[next_summoner] = info.model;
        heroName[next_summoner] = info.name;
        (
            uint256 _heroId,
            uint256 _atkValue,
            uint256 _atkSpeed,
            uint256 _magicValue
        ) = _getInitAbility(info.quality, info.occupation);
        heroId[next_summoner] = _heroId;
        atkValue[next_summoner] = _atkValue;
        atkSpeed[next_summoner] = _atkSpeed;
        magicValue[next_summoner] = _magicValue;
        emit summoned(
            info.owner,
            next_summoner,
            info.name,
            info.level,
            info.quality,
            info.occupation,
            _atkValue,
            _atkSpeed,
            _magicValue,
            _heroId,
            info.model
        );
        next_summoner++;
    }

    function _roll()
        private
        returns (
            uint256 qualityVal,
            uint256 classVal,
            uint256 modelVal
        )
    {
        //普通 55%（蓝），优秀30%（绿），精英13%（紫），传说1.9%，稀世0.1%
        uint16 qualityRandom = uint16(_random(10000));
        if (qualityRandom < 10) {
            qualityVal = 5;
        } else if (qualityRandom < 200) {
            qualityVal = 4;
        } else if (qualityRandom < 1500) {
            qualityVal = 3;
        } else if (qualityRandom < 4500) {
            qualityVal = 2;
        } else {
            qualityVal = 1;
        }

        uint16 classRandom = uint16(_random(10000));
        if (classRandom < 3333) {
            classVal = 1;
        } else if (classRandom >= 3333 && classRandom < 6666) {
            classVal = 2;
        } else {
            classVal = 3;
        }

        uint16 modelRandom = uint16(_random(10000));
        if (modelRandom < 3333) {
            modelVal = 1;
        } else if (modelRandom >= 3333 && modelRandom < 6666) {
            modelVal = 2;
        } else {
            modelVal = 3;
        }
        return (qualityVal, classVal, modelVal);
    }

    function _getInitAbility(uint256 _quality, uint256 _occupation)
        private
        returns (
            uint256 _heroId,
            uint256 _atkValue,
            uint256 _atkSpeed,
            uint256 _magicValue
        )
    {
        PubConfig memory config = hc.initAbilityScore(_quality, _occupation);
        return (
            config.heroId,
            _randomBetween(config.atkValueLow, config.atkValueUp),
            _randomBetween(config.atkSpeedLow, config.atkSpeedUp),
            _randomBetween(config.magicValueLow, config.magicValueUp)
        );
    }

    function _randomBetween(uint256 low, uint256 up) private returns (uint256) {
        return low + _random(up - low);
    }

    function setPledged(uint256 _summoner, bool _isPledged) external {
        require(
            _isCallFromAllowedPledgeFromAddresses(),
            "Hero: Address not available."
        );
        isPledged[_summoner] = _isPledged;
    }

    function setAdventuring(uint256 _summoner, bool _isAdventuring) external {
        require(
            _isCallFromAllowedUpdateAdventuringAddresses(),
            "Hero: Address not available."
        );
        isAdventuring[_summoner] = _isAdventuring;
    }

    function addAllowedPledgeFromAddress(address _address) external onlyOwner {
        require(_address != address(0), "Hero: None zero address.");
        allowedPledgeFromAddresses.push(_address);
    }

    function removeAllowedPledgeFromAddress(address _address)
        external
        onlyOwner
    {
        require(_address != address(0), "Hero: None zero address.");
        _addressArrayDelete(allowedPledgeFromAddresses, _address);
    }

    function updateWallet(address _address) external onlyOwner {
        require(_address != address(0), "Hero: None zero address.");
        wallet = _address;
    }

    function _isCallFromAllowedPledgeFromAddresses()
        private
        view
        returns (bool)
    {
        return
            allowedPledgeFromAddresses.length > 0 &&
            _addressesContains(allowedPledgeFromAddresses, msg.sender);
    }

    function addAllowedUpdateAdventuringAddresses(address _address)
        external
        onlyOwner
    {
        require(_address != address(0), "Hero: None zero address.");
        allowedUpdateAdventuringAddresses.push(_address);
    }

    function removeAllowedUpdateAdventuringAddresses(address _address)
        external
        onlyOwner
    {
        require(_address != address(0), "Hero: None zero address.");
        _addressArrayDelete(allowedUpdateAdventuringAddresses, _address);
    }

    function _isCallFromAllowedUpdateAdventuringAddresses()
        private
        view
        returns (bool)
    {
        return
            allowedUpdateAdventuringAddresses.length > 0 &&
            _addressesContains(allowedUpdateAdventuringAddresses, msg.sender);
    }

    function _random(uint256 _length) private returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), msg.sender, _seed)
            )
        );
        _seed = randomNumber;
        return randomNumber % _length;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(!isWorking(tokenId), "Hero: Hero is staked or in the battle.");
        super._beforeTokenTransfer(from, to, tokenId);
        it.clearWearingItems(tokenId);
    }

    function setItemAddress(address _itAddr) external onlyOwner {
        it = Item(_itAddr);
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

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_exists(_tokenId), "Hero: This hero does not exist.");
        bytes memory tokenIdBytes = toBytes(_tokenId);
        bytes memory hostBytes = "https://www.undoomed.space/hero/";
        bytes memory buffer = new bytes(hostBytes.length + tokenIdBytes.length);
        for (uint256 i = 0; i < hostBytes.length; i++) {
            buffer[i] = hostBytes[i];
        }
        for (uint256 i = 0; i < buffer.length - hostBytes.length; i++) {
            buffer[i + hostBytes.length] = tokenIdBytes[i];
        }
        return string(buffer);
    }

    function toBytes(uint256 value) internal pure returns (bytes memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return buffer;
    }

    modifier onlyOwner() {
        require(contractCreator == msg.sender, "Hero: Caller is not the owner");
        _;
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
