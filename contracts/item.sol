// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ERC721Enumerable} from "./erc721.sol";
import {ItemAttribute, ItemConfig} from "./item_config.sol";
import {Hero} from "./hero.sol";
import {HeroInfo} from "./hero_config.sol";
import {IERC20} from "./IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Item is ERC721Enumerable, Initializable {
    Hero private he;
    ItemConfig private ic;
    IERC20 private usdt;
    IERC20 private crystal;

    address public wallet;
    address public contractCreator;
    address[] public allowedOpenItemAddresses;

    string public constant name = "Undoomed-Item";
    string public constant symbol = "UDI";
    uint8 constant usdtDecimals = 6;
    uint256 public nextItem;

    mapping(uint256 => string) public itemName;
    mapping(uint256 => uint256) public level;
    mapping(uint256 => uint256) public itemId;
    mapping(uint256 => uint256) public itemType;
    mapping(uint256 => bool) public isWeared;
    mapping(uint256 => uint256) public wearedTimestamp;

    mapping(uint256 => uint256[19]) public wearingItemConfigIds;
    mapping(uint256 => uint256[19]) public wearingItemTokenIds;

    IERC20 private croesus;
    mapping(uint256 => uint256) wearedSummoner;
    uint256 private _seed;

    struct ItemInfo {
        uint256 id;
        string itemName;
        uint256 level;
        uint256 itemId;
        uint256 itemType;
        bool isWeared;
        uint256 wearedTimestamp;
        uint256 wearedSummoner;
    }

    struct SummonerWeardItems {
        uint256 summoner;
        uint256[19] itemConfigIds;
        uint256[19] itemTokenIds;
    }

    event opened(
        address indexed owner,
        uint256 item,
        uint256 level,
        uint256 itemType,
        uint256 itemId,
        string itemName
    );

    event OpenItemRandomResult(
        address indexed owner,
        bool success,
        uint256 item,
        uint256 level,
        uint256 itemType,
        uint256 itemId,
        string itemName
    );

    event ItemWeared(
        address indexed owner,
        uint256 summoner,
        uint256 itemTokenId,
        uint256 itemId,
        uint256 index
    );

    event ItemRemoved(
        address indexed owner,
        uint256 summoner,
        uint256 itemTokenId,
        uint256 itemId,
        uint256 index
    );

    event ItemMerged(
        address indexed owner,
        uint256 item,
        uint256 level,
        uint256 itemType,
        uint256 itemId,
        string itemName
    );

    event ItemsCleared(address indexed owner, uint256 summoner);

    function initialize(
        address _heroAddress,
        address _itemConfigAddress,
        address _usdtAddr,
        address _crystalAddr,
        address _walletAddr
    ) public initializer {
        nextItem = 1;
        he = Hero(_heroAddress);
        ic = ItemConfig(_itemConfigAddress);
        usdt = IERC20(_usdtAddr);
        crystal = IERC20(_crystalAddr);
        contractCreator = msg.sender;
        wallet = _walletAddr;
    }

    function mergeItems(uint256 _destinationId, uint256[5] memory _itemTokenIds)
        external
    {
        uint256[5] memory requireIds = ic.mergeRequireItemsById(_destinationId);
        require(requireIds[0] != 0, "Item: Unknown ID of medged item.");
        _consumeCroesus(msg.sender, 5 * 1e18);
        crystal.transferFrom(msg.sender, wallet, 1000 * 1e18);
        uint256[5] memory configIds;
        for (uint256 i; i < 5; i++) {
            uint256 _item = _itemTokenIds[i];
            require(
                _isApprovedOrOwner(msg.sender, _item),
                "Item: Wrong owner."
            );
            configIds[i] = itemId[_item];
        }
        for (uint256 i; i < 5; i++) {
            uint256 requireId = requireIds[i];
            bool find;
            for (uint256 j; j < 5; j++) {
                uint256 _itemId = configIds[j];
                if (_itemId == requireId) {
                    find = true;
                    uint256 _item = _itemTokenIds[j];
                    _burn(_item);
                    break;
                }
            }
            if (!find) {
                require(false, "Item: No required item.");
            }
        }
        ItemAttribute memory attr = ic.itemById(_destinationId);
        uint256 _nextItem = nextItem;
        _mintItem(attr, _destinationId, msg.sender);
        emit ItemMerged(
            msg.sender,
            _nextItem,
            attr.level,
            attr.itemType,
            _destinationId,
            attr.name
        );
    }

    function _consumeCroesus(address sender, uint256 amount) private {
        // （1）销毁：20%自动进入销毁地址；
        croesus.transferFrom(sender, address(0), (amount * 20) / 100);
        croesus.transferFrom(sender, wallet, (amount * 80) / 100);
    }

    function updateCroesus(address _address) external onlyOwner {
        require(_address != address(0), "Item: None zero address.");
        croesus = IERC20(_address);
    }

    function updateWallet(address _address) external onlyOwner {
        require(_address != address(0), "Item: None zero address.");
        wallet = _address;
    }

    function open(uint256 _type) external {
        usdt.transferFrom(msg.sender, wallet, 15 * 10**usdtDecimals);
        (
            address _owner,
            uint256 _item,
            uint256 _level,
            uint256 _itemType,
            uint256 _itemId,
            string memory _itemName
        ) = _open(_type, msg.sender);
        emit opened(_owner, _item, _level, _itemType, _itemId, _itemName);
    }

    function _open(uint256 _type, address _desAddr)
        private
        returns (
            address _owner,
            uint256 _item,
            uint256 _level,
            uint256 _itemType,
            uint256 _itemId,
            string memory _itemName
        )
    {
        require(_type == 2 || _type == 3, "Item: Wrong type.");
        (ItemAttribute memory attr, uint256 itemConfigId) = _roll(_type);
        _item = nextItem;
        _mintItem(attr, itemConfigId, _desAddr);
        _owner = _desAddr;
        _level = attr.level;
        _itemType = attr.itemType;
        _itemId = itemConfigId;
        _itemName = attr.name;
    }

    function _mintItem(
        ItemAttribute memory attr,
        uint256 itemConfigId,
        address _desAddr
    ) private {
        level[nextItem] = attr.level;
        itemType[nextItem] = attr.itemType;
        itemId[nextItem] = itemConfigId;
        itemName[nextItem] = attr.name;
        _safeMint(_desAddr, nextItem);
        nextItem++;
    }

    function openItemRandom(address _des, uint256 _randomCount) public {
        require(
            _isCallFromAllowedOpenItemAddresses(),
            "Item: Address not available."
        );
        uint256 randNum = _random(_randomCount);
        if (0 == randNum) {
            uint256 _type = 2;
            if (_random(2) == 1) {
                _type = 3;
            }
            (
                ,
                uint256 _item,
                uint256 _level,
                uint256 _itemType,
                uint256 _itemId,
                string memory _itemName
            ) = _open(_type, _des);
            emit OpenItemRandomResult(
                _des,
                true,
                _item,
                _level,
                _itemType,
                _itemId,
                _itemName
            );
        } else {
            emit OpenItemRandomResult(_des, false, 0, 0, 0, 0, "");
        }
    }

    function recycle(uint256 _item) external {
        require(_isApprovedOrOwner(msg.sender, _item), "Item: Wrong owner.");
        require(!isUsing(_item), "Item: Item is in use.");
        uint256 _itemId = itemId[_item];
        ItemAttribute memory _attr = ic.itemById(_itemId);
        uint256 recoveryPay = uint256(_attr.recoveryPayNumber) * 1e18;
        _burn(_item);
        crystal.mint(msg.sender, recoveryPay);
    }

    function items(uint256[] memory _items)
        external
        view
        returns (ItemInfo[] memory)
    {
        require(_items.length <= 50, "Item: Size of batch can not exceed 50.");
        ItemInfo[] memory list = new ItemInfo[](_items.length);
        for (uint256 i = 0; i < _items.length; i++) {
            uint256 _item = _items[i];
            list[i] = ItemInfo(
                _item,
                itemName[_item],
                level[_item],
                itemId[_item],
                itemType[_item],
                isWeared[_item],
                wearedTimestamp[_item],
                wearedSummoner[_item]
            );
        }
        return list;
    }

    struct HeroInfoWithItems {
        HeroInfo heroInfo;
        SummonerWeardItems items;
    }

    function summonersWithItems(uint256[] memory _summoners)
        public
        view
        returns (HeroInfoWithItems[] memory)
    {
        require(
            _summoners.length <= 50,
            "Item: Size of batch can not exceed 50."
        );
        HeroInfo[] memory heroInfos = he.summoners(_summoners);
        SummonerWeardItems[] memory itemInfos = getSummonersWeardItems(
            _summoners
        );
        HeroInfoWithItems[] memory list = new HeroInfoWithItems[](
            _summoners.length
        );
        for (uint256 i = 0; i < _summoners.length; i++) {
            list[i] = HeroInfoWithItems(heroInfos[i], itemInfos[0]);
        }
        return list;
    }

    function getSummonersWeardItems(uint256[] memory _summoners)
        public
        view
        returns (SummonerWeardItems[] memory)
    {
        require(
            _summoners.length <= 50,
            "Item: Size of batch can not exceed 50."
        );
        SummonerWeardItems[] memory list = new SummonerWeardItems[](
            _summoners.length
        );
        for (uint256 i = 0; i < _summoners.length; i++) {
            uint256 _summoner = _summoners[i];
            uint256[19] memory _configIds = wearingItemConfigIds[_summoner];
            uint256[19] memory _items = wearingItemTokenIds[_summoner];
            list[i] = SummonerWeardItems(_summoner, _configIds, _items);
        }
        return list;
    }

    function getWearingItems(uint256 _summoner)
        external
        view
        returns (uint256[19] memory _x)
    {
        return wearingItemConfigIds[_summoner];
    }

    function isUsing(uint256 _item) public view returns (bool) {
        return isWeared[_item];
    }

    function _removeItem(
        uint256 _summoner,
        uint256 index,
        uint256 _item
    ) private {
        uint256[19] storage _wearingConfigIds = wearingItemConfigIds[_summoner];
        uint256[19] storage _wearingItemTokenIds = wearingItemTokenIds[
            _summoner
        ];
        require(
            wearedTimestamp[_item] < block.timestamp - 12 hours,
            "Item: Can be removed after 12 hours."
        );
        isWeared[_item] = false;
        _wearingConfigIds[index] = 0;
        _wearingItemTokenIds[index] = 0;
        wearedTimestamp[_item] = 0;
        emit ItemRemoved(
            msg.sender,
            _summoner,
            _item,
            _wearingConfigIds[index],
            index
        );
    }

    function _wearItem(
        uint256 _summoner,
        uint256 index,
        uint256 _item
    ) private {
        uint256[19] storage _wearingConfigIds = wearingItemConfigIds[_summoner];
        require(_isApprovedOrOwnerOfItem(_item), "Item: Wrong owner.");
        require(!isUsing(_item), "Item: Item is in use.");
        uint256 _itemId = itemId[_item];
        if (index >= 11) {
            require(
                !_arrayContains(_wearingConfigIds, _itemId),
                "Item: Equip same magic scroll twice is not allowed."
            );
        }
        ItemAttribute memory attr = ic.itemById(_itemId);
        uint256 position = attr.position;
        require(position != 0, "Item: No such item.");
        if (position <= 7) {
            require(index == position - 1, "Item: Wrong slot.");
        } else if (position == 8) {
            require(index < 11 && index >= 7, "Item: Wrong slot.");
        } else if (position == 9) {
            require(index < 19 && index >= 11, "Item: Wrong slot.");
        }
        wearingItemConfigIds[_summoner][index] = _itemId;
        wearingItemTokenIds[_summoner][index] = _item;
        isWeared[_item] = true;
        wearedTimestamp[_item] = block.timestamp;
        wearedSummoner[_item] = _summoner;
        emit ItemWeared(msg.sender, _summoner, _item, _itemId, index);
    }

    function wearItems(uint256 _summoner, uint256[19] memory _items) external {
        require(
            _isApprovedOrOwnerOfSummoner(_summoner),
            "Item: Not the hero's owner."
        );
        uint256[19] storage _wearingItemTokenIds = wearingItemTokenIds[
            _summoner
        ];
        for (uint256 index = 0; index < _items.length; index++) {
            uint256 _item = _items[index];
            uint256 _oldItem = _wearingItemTokenIds[index];
            if (_item != _oldItem && _oldItem > 0) {
                _removeItem(_summoner, index, _oldItem);
            }
        }
        for (uint256 index = 0; index < _items.length; index++) {
            uint256 _item = _items[index];
            uint256 _oldItem = _wearingItemTokenIds[index];
            if (_item > 0 && _oldItem != _item) {
                require(_oldItem == 0, "Item: Can be removed after 12 hours.");
                _wearItem(_summoner, index, _item);
            }
        }
    }

    function removeAllExpiredItems(uint256 _summoner) external {
        require(
            _isApprovedOrOwnerOfSummoner(_summoner),
            "Item: Not the hero's owner."
        );
        uint256[19] storage configIds = wearingItemConfigIds[_summoner];
        uint256[19] storage tokenIds = wearingItemTokenIds[_summoner];
        for (uint256 index = 0; index < 19; index++) {
            uint256 _item = tokenIds[index];
            if (_item > 0) {
                if (wearedTimestamp[_item] < block.timestamp - 12 hours) {
                    emit ItemRemoved(
                        msg.sender,
                        _summoner,
                        _item,
                        configIds[index],
                        index
                    );
                    isWeared[_item] = false;
                    wearedTimestamp[_item] = 0;
                    configIds[index] = 0;
                    tokenIds[index] = 0;
                }
            }
        }
        emit ItemsCleared(msg.sender, _summoner);
    }

    function clearWearingItems(uint256 _summoner) external {
        require(msg.sender == address(he), "Item: Not Hero Contract.");
        _clearWearingItems(_summoner);
    }

    function _clearWearingItems(uint256 _summoner) private {
        uint256[19] storage configIds = wearingItemConfigIds[_summoner];
        uint256[19] storage tokenIds = wearingItemTokenIds[_summoner];
        for (uint256 index = 0; index < 19; index++) {
            uint256 _item = tokenIds[index];
            if (_item > 0) {
                require(
                    wearedTimestamp[_item] < block.timestamp - 12 hours,
                    "Item: Can be removed after 12 hours."
                );
                isWeared[_item] = false;
                wearedTimestamp[_item] = 0;
                configIds[index] = 0;
                tokenIds[index] = 0;
            }
        }
    }

    function addAllowedOpenItemAddress(address _address) external onlyOwner {
        allowedOpenItemAddresses.push(_address);
    }

    function removeAllowedOpenItemAddress(address _address) external onlyOwner {
        require(_address != address(0), "Item: None zero address.");
        _addressArrayDelete(allowedOpenItemAddresses, _address);
    }

    function _isCallFromAllowedOpenItemAddresses() private view returns (bool) {
        return
            allowedOpenItemAddresses.length > 0 &&
            _addressesContains(allowedOpenItemAddresses, msg.sender);
    }

    function _arrayFirstZeroIndex(uint256[8] memory array)
        private
        pure
        returns (uint256)
    {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == 0) {
                return index;
            }
        }
        return 9;
    }

    function _arrayContains(uint256[19] memory array, uint256 content)
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

    function _roll(uint256 _type)
        private
        returns (ItemAttribute memory _attr, uint256 _itemId)
    {
        uint256 randNum = _random(10000);
        uint256 _level = 1;
        if (randNum >= 9900) {
            _level = 5;
        } else if (randNum >= 9500) {
            _level = 4;
        } else if (randNum >= 8000) {
            _level = 3;
        } else if (randNum >= 5000) {
            _level = 2;
        } else if (randNum >= 0) {
            _level = 1;
        }
        uint256[] memory ids;
        if (_type == 2) {
            ids = ic.equipmentItemIdsByLevel(_level);
        } else if (_type == 3) {
            ids = ic.skillItemIdsByLevel(_level);
        }
        if (ids.length > 0) {
            _itemId = ids[_random(ids.length)];
            _attr = ic.itemById(_itemId);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(!isUsing(tokenId), "Item: Item is in use.");
        super._beforeTokenTransfer(from, to, tokenId);
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

    function _isApprovedOrOwnerOfItem(uint256 _item)
        internal
        view
        returns (bool)
    {
        return getApproved(_item) == msg.sender || ownerOf(_item) == msg.sender;
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

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_exists(_tokenId), "Item: This item does not exist.");
        return
            string(
                abi.encodePacked(
                    "https://www.undoomed.space/item/",
                    toBytes(_tokenId),
                    "?n=",
                    itemName[_tokenId],
                    "&t=",
                    toBytes(itemType[_tokenId]),
                    "&l=",
                    toBytes(level[_tokenId]),
                    "&i=",
                    toBytes(itemId[_tokenId])
                )
            );
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
        require(
            contractCreator == msg.sender,
            "Item: Caller is not the owner."
        );
        _;
    }
}
