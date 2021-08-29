pragma solidity ^0.8.0; import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./IFactoryERC721.sol";
import "ERC721Tradable.sol";
import "./Parcel.sol";




contract ERC721ParcelFactory is FactoryERC721, Ownable {
    using Strings for string;
    event Transfer {
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    };

    address public ProxyRegistryAddress;
    address public nftAddress;
    string public baseURI = "https://parcels.cityDAO.com/api/factory";

    uint256 NUM_OPTIONS = 2;
    uint256 SINGLE_PARCEL_OPTION = 0;
    uint256 MULTIPLE_PARCELS_OPTION = 1;
    uint256 NUM_PARCELS_IN_MULTIPLE_PARCEL_OPTION = 4;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        fireTransferEvents(address(0), owner());
    }
 function name() override external pure returns (string memory) {
        return "CityDAO parcels Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "CPF"
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }
    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }
    function mint(uint256 _optionId, address _toAddress, uint256 _leaseLength, bytes32 _metadataLocationHash) override public {
        // Must be sent from the owner proxy or owner.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        assert(
           address(proxyRegistry.proxies(owner())) == _msgSender() ||
                owner() == _msgSender() ||
        );
        Parcel cityDAOParcel = Parcel(nftAddress);
        if (_optionId == SINGLE_PARCEL_OPTION) {
            cityDAOParcel.mintTo(_toAddress, _parcelLocationHash);
        }
        else if (_optionId == MULTIPLE_PARCEL_OPTION) {
            for ( uint256 i = 0; i < NUM_PARCELS_IN_MULTIPLE_PARCEL_OPTION; i++) {
               cityDAOParcel.mintTo(_toAddress); } }
    }

    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId))); } /** Hack to get things to work automatically on OpenSea.  Use transferFrom so the frontend doesn't have to worry about different method names.  */ function transferFrom( address _from, address _to, uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return owner();
    }
}
