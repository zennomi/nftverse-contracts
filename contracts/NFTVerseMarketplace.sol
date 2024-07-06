// SPDX-License-Identifier: MIT
// Author: Zennomi
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* NFT Marketplace
    List NFT, 
    Buy NFT, 
    Offer NFT, 
    Accept offer, 
    Create auction, 
    Bid place,
    & support Royalty
*/
contract NFTVerseMarketplace is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint256 private platformFee;
    address private feeRecipient;

    struct ListNFT {
        address nft;
        uint256 tokenId;
        address seller;
        address payToken;
        uint256 price;
        bool sold;
    }

    struct OfferNFT {
        address nft;
        uint256 tokenId;
        address offerer;
        address payToken;
        uint256 offerPrice;
        bool accepted;
    }

    struct AuctionNFT {
        address nft;
        uint256 tokenId;
        address creator;
        address payToken;
        uint256 initialPrice;
        uint256 minBid;
        uint256 startTime;
        uint256 endTime;
        address lastBidder;
        uint256 heighestBid;
        address winner;
        bool success;
    }

    mapping(address => bool) private payableToken;
    address[] private tokens;

    // nft => tokenId => list struct
    mapping(address => mapping(uint256 => ListNFT)) private listNfts;

    // nft => tokenId => offerer address => offer struct
    mapping(address => mapping(uint256 => mapping(address => OfferNFT)))
        private offerNfts;

    // nft => tokenId => acuton struct
    mapping(address => mapping(uint256 => AuctionNFT)) private auctionNfts;

    // auciton index => bidding counts => bidder address => bid price
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        private bidPrices;

    // events
    event ListedNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        address indexed seller
    );
    event CanceledListedNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed seller
    );
    event BoughtNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        address seller,
        address indexed buyer
    );
    event OfferredNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 offerPrice,
        address indexed offerer
    );
    event CanceledOfferredNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 offerPrice,
        address indexed offerer
    );
    event AcceptedNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 offerPrice,
        address offerer,
        address indexed nftOwner
    );
    event CreatedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        uint256 minBid,
        uint256 startTime,
        uint256 endTime,
        address indexed creator
    );
    event PlacedBid(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 bidPrice,
        address indexed bidder
    );
    event CanceledAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed creator
    );

    event ResultedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address creator,
        address indexed winner,
        uint256 price,
        address caller
    );

    event AddPayableToken(address indexed tokenAddress);

    function initialize(
        uint256 _platformFee,
        address _feeRecipient
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        require(_platformFee <= 10000, "can't more than 10 percent");
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
        payableToken[address(0)] = true;
    }

    modifier isListedNFT(address _nft, uint256 _tokenId) {
        ListNFT memory listedNFT = listNfts[_nft][_tokenId];
        require(
            listedNFT.seller != address(0) && !listedNFT.sold,
            "not listed"
        );
        _;
    }

    modifier isNotListedNFT(address _nft, uint256 _tokenId) {
        ListNFT memory listedNFT = listNfts[_nft][_tokenId];
        require(
            listedNFT.seller == address(0) || listedNFT.sold,
            "already listed"
        );
        _;
    }

    modifier isAuction(address _nft, uint256 _tokenId) {
        AuctionNFT memory auction = auctionNfts[_nft][_tokenId];
        require(
            auction.nft != address(0) && !auction.success,
            "auction was not created"
        );
        _;
    }

    modifier isNotAuction(address _nft, uint256 _tokenId) {
        AuctionNFT memory auction = auctionNfts[_nft][_tokenId];
        require(
            auction.nft == address(0) || auction.success,
            "auction already created"
        );
        _;
    }

    modifier isOfferredNFT(
        address _nft,
        uint256 _tokenId,
        address _offerer
    ) {
        OfferNFT memory offer = offerNfts[_nft][_tokenId][_offerer];
        require(
            offer.offerPrice > 0 && offer.offerer != address(0),
            "not offerred nft"
        );
        _;
    }

    modifier isPayableToken(address _payToken) {
        require(payableToken[_payToken], "invalid pay token");
        _;
    }

    // @notice List NFT on Marketplace
    function listNft(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external isPayableToken(_payToken) {
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_tokenId) == msg.sender, "not nft owner");
        nft.transferFrom(msg.sender, address(this), _tokenId);

        listNfts[_nft][_tokenId] = ListNFT({
            nft: _nft,
            tokenId: _tokenId,
            seller: msg.sender,
            payToken: _payToken,
            price: _price,
            sold: false
        });

        emit ListedNFT(_nft, _tokenId, _payToken, _price, msg.sender);
    }

    // @notice Cancel listed NFT
    function cancelListedNFT(
        address _nft,
        uint256 _tokenId
    ) external isListedNFT(_nft, _tokenId) {
        ListNFT memory listedNFT = listNfts[_nft][_tokenId];
        require(listedNFT.seller == msg.sender, "not listed owner");
        IERC721(_nft).transferFrom(address(this), msg.sender, _tokenId);
        delete listNfts[_nft][_tokenId];
        emit CanceledListedNFT(_nft, _tokenId, msg.sender);
    }

    // @notice Buy listed NFT
    function buyNFT(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external isListedNFT(_nft, _tokenId) {
        ListNFT storage listedNft = listNfts[_nft][_tokenId];
        require(
            _payToken != address(0) && _payToken == listedNft.payToken,
            "invalid pay token"
        );
        require(!listedNft.sold, "nft already sold");
        require(_price >= listedNft.price, "invalid price");

        // Calculate & Transfer platfrom fee
        uint256 platformFeeTotal = calculatePlatformFee(_price);
        IERC20(listedNft.payToken).transferFrom(
            msg.sender,
            feeRecipient,
            platformFeeTotal
        );

        // Transfer to nft owner
        IERC20(listedNft.payToken).transferFrom(
            msg.sender,
            listedNft.seller,
            _price - platformFeeTotal
        );

        // Transfer NFT to buyer
        _buyNFT(listedNft, _price);
    }

    function buyNFTs(
        address[] memory _nfts,
        uint256[] memory _tokenIds,
        address[] memory _payTokens,
        uint256[] memory _prices
    ) external {
        require(_nfts.length == _tokenIds.length, "invalid params");
        require(_nfts.length == _prices.length, "invalid params");

        for (uint256 i = 0; i < _nfts.length; i++) {
            ListNFT storage listedNft = listNfts[_nfts[i]][_tokenIds[i]];
            require(
                listedNft.seller != address(0) && !listedNft.sold,
                "not listed"
            );
            require(
                _payTokens[i] != address(0) &&
                    _payTokens[i] == listedNft.payToken,
                "invalid pay token"
            );
            require(!listedNft.sold, "nft already sold");
            require(_prices[i] >= listedNft.price, "invalid price");
            // Calculate & Transfer platfrom fee
            uint256 platformFeeTotal = calculatePlatformFee(_prices[i]);
            IERC20(listedNft.payToken).transferFrom(
                msg.sender,
                feeRecipient,
                platformFeeTotal
            );

            // Transfer to nft owner
            IERC20(listedNft.payToken).transferFrom(
                msg.sender,
                listedNft.seller,
                _prices[i] - platformFeeTotal
            );

            // Transfer NFT to buyer
            _buyNFT(listedNft, _prices[i]);
        }
    }

    function buyNFTsByETH(
        address[] memory _nfts,
        uint256[] memory _tokenIds,
        uint256[] memory _prices
    ) external payable {
        require(_nfts.length == _tokenIds.length, "invalid params");
        require(_nfts.length == _prices.length, "invalid params");

        uint256 totalPrice;
        for (uint256 i = 0; i < _nfts.length; i++) {
            totalPrice += _prices[i];
        }

        require(msg.value >= totalPrice, "invalid msg.value");

        for (uint256 i = 0; i < _nfts.length; i++) {
            ListNFT storage listedNft = listNfts[_nfts[i]][_tokenIds[i]];
            uint256 _price = _prices[i];
            require(listedNft.payToken == address(0), "invalid pay token");
            require(!listedNft.sold, "nft already sold");
            require(_price >= listedNft.price, "invalid price");

            // Calculate & Transfer platfrom fee
            uint256 platformFeeTotal = calculatePlatformFee(_price);
            payable(feeRecipient).transfer(platformFeeTotal);

            // Transfer to nft owner
            payable(listedNft.seller).transfer(_price - platformFeeTotal);

            // Transfer NFT to buyer
            _buyNFT(listedNft, _price);
        }
    }

    function buyNFTByETH(
        address _nft,
        uint256 _tokenId
    ) external payable isListedNFT(_nft, _tokenId) {
        ListNFT storage listedNft = listNfts[_nft][_tokenId];
        uint256 _price = msg.value;
        require(listedNft.payToken == address(0), "invalid pay token");
        require(!listedNft.sold, "nft already sold");
        require(_price >= listedNft.price, "invalid price");

        // Calculate & Transfer platfrom fee
        uint256 platformFeeTotal = calculatePlatformFee(_price);
        payable(feeRecipient).transfer(platformFeeTotal);

        // Transfer to nft owner
        payable(listedNft.seller).transfer(_price - platformFeeTotal);

        // Transfer NFT to buyer
        _buyNFT(listedNft, _price);
    }

    function _buyNFT(ListNFT storage listedNft, uint256 _price) internal {
        listedNft.sold = true;

        // Transfer NFT to buyer
        IERC721(listedNft.nft).safeTransferFrom(
            address(this),
            msg.sender,
            listedNft.tokenId
        );

        emit BoughtNFT(
            listedNft.nft,
            listedNft.tokenId,
            listedNft.payToken,
            _price,
            listedNft.seller,
            msg.sender
        );
    }

    // @notice Offer listed NFT
    function offerNFT(
        address _nft,
        uint256 _tokenId,
        uint256 _offerPrice
    ) external isListedNFT(_nft, _tokenId) {
        require(_offerPrice > 0, "price can not 0");
        ListNFT memory nft = listNfts[_nft][_tokenId];
        require(nft.payToken != address(0), "invalid pay token");

        IERC20(nft.payToken).transferFrom(
            msg.sender,
            address(this),
            _offerPrice
        );

        _offerNFT(nft, _offerPrice);
    }

    function offerNFTByETH(
        address _nft,
        uint256 _tokenId
    ) external payable isListedNFT(_nft, _tokenId) {
        uint256 _offerPrice = msg.value;
        require(_offerPrice > 0, "price can not 0");

        ListNFT memory nft = listNfts[_nft][_tokenId];
        require(nft.payToken == address(0), "invalid pay token");

        _offerNFT(nft, _offerPrice);
    }

    function _offerNFT(ListNFT memory nft, uint256 _offerPrice) internal {
        offerNfts[nft.nft][nft.tokenId][msg.sender] = OfferNFT({
            nft: nft.nft,
            tokenId: nft.tokenId,
            offerer: msg.sender,
            payToken: nft.payToken,
            offerPrice: _offerPrice,
            accepted: false
        });

        emit OfferredNFT(
            nft.nft,
            nft.tokenId,
            nft.payToken,
            _offerPrice,
            msg.sender
        );
    }

    // @notice Offerer cancel offerring
    function cancelOfferNFT(
        address _nft,
        uint256 _tokenId
    ) external isOfferredNFT(_nft, _tokenId, msg.sender) {
        OfferNFT memory offer = offerNfts[_nft][_tokenId][msg.sender];
        require(offer.offerer == msg.sender, "not offerer");
        require(!offer.accepted, "offer already accepted");
        if (offer.payToken == address(0)) {
            payable(offer.offerer).transfer(offer.offerPrice);
        } else {
            IERC20(offer.payToken).transfer(offer.offerer, offer.offerPrice);
        }
        _cancelOfferNFT(offer);
    }

    function _cancelOfferNFT(OfferNFT memory offer) internal {
        delete offerNfts[offer.nft][offer.tokenId][msg.sender];

        emit CanceledOfferredNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            msg.sender
        );
    }

    // @notice listed NFT owner accept offerring
    function acceptOfferNFT(
        address _nft,
        uint256 _tokenId,
        address _offerer
    )
        external
        isOfferredNFT(_nft, _tokenId, _offerer)
        isListedNFT(_nft, _tokenId)
    {
        require(
            listNfts[_nft][_tokenId].seller == msg.sender,
            "not listed owner"
        );
        OfferNFT storage offer = offerNfts[_nft][_tokenId][_offerer];
        ListNFT storage list = listNfts[offer.nft][offer.tokenId];
        require(!list.sold, "already sold");
        require(!offer.accepted, "offer already accepted");

        list.sold = true;
        offer.accepted = true;

        uint256 offerPrice = offer.offerPrice;
        uint256 totalPrice = offerPrice;

        uint256 platformFeeTotal = calculatePlatformFee(offerPrice);
        if (offer.payToken == address(0)) {
            // Calculate & Transfer platfrom fee
            payable(feeRecipient).transfer(platformFeeTotal);

            // Transfer to seller
            payable(list.seller).transfer(totalPrice - platformFeeTotal);
        } else {
            IERC20 payToken = IERC20(offer.payToken);

            // Calculate & Transfer platfrom fee
            payToken.transfer(feeRecipient, platformFeeTotal);

            // Transfer to seller
            payToken.transfer(list.seller, totalPrice - platformFeeTotal);
        }

        // Transfer NFT to offerer
        IERC721(list.nft).safeTransferFrom(
            address(this),
            offer.offerer,
            list.tokenId
        );

        emit AcceptedNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            offer.offerer,
            list.seller
        );
    }

    // @notice Create autcion
    function createAuction(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price,
        uint256 _minBid,
        uint256 _startTime,
        uint256 _endTime
    ) external isPayableToken(_payToken) isNotAuction(_nft, _tokenId) {
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_tokenId) == msg.sender, "not nft owner");
        require(_endTime > _startTime, "invalid end time");

        nft.transferFrom(msg.sender, address(this), _tokenId);

        auctionNfts[_nft][_tokenId] = AuctionNFT({
            nft: _nft,
            tokenId: _tokenId,
            creator: msg.sender,
            payToken: _payToken,
            initialPrice: _price,
            minBid: _minBid,
            startTime: _startTime,
            endTime: _endTime,
            lastBidder: address(0),
            heighestBid: _price,
            winner: address(0),
            success: false
        });

        emit CreatedAuction(
            _nft,
            _tokenId,
            _payToken,
            _price,
            _minBid,
            _startTime,
            _endTime,
            msg.sender
        );
    }

    // @notice Cancel auction
    function cancelAuction(
        address _nft,
        uint256 _tokenId
    ) external isAuction(_nft, _tokenId) {
        AuctionNFT memory auction = auctionNfts[_nft][_tokenId];
        require(auction.creator == msg.sender, "not auction creator");
        require(auction.lastBidder == address(0), "already have bidder");

        IERC721 nft = IERC721(_nft);
        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete auctionNfts[_nft][_tokenId];

        emit CanceledAuction(_nft, _tokenId, msg.sender);
    }

    // @notice Bid place auction
    function bidPlace(
        address _nft,
        uint256 _tokenId,
        uint256 _bidPrice
    ) external isAuction(_nft, _tokenId) {
        require(
            block.timestamp >= auctionNfts[_nft][_tokenId].startTime,
            "auction not start"
        );
        require(
            block.timestamp <= auctionNfts[_nft][_tokenId].endTime,
            "auction ended"
        );
        require(
            _bidPrice >=
                auctionNfts[_nft][_tokenId].heighestBid +
                    auctionNfts[_nft][_tokenId].minBid,
            "less than min bid price"
        );

        AuctionNFT storage auction = auctionNfts[_nft][_tokenId];

        require(auction.payToken != address(0), "invalid pay token");
        IERC20 payToken = IERC20(auction.payToken);
        payToken.transferFrom(msg.sender, address(this), _bidPrice);

        if (auction.lastBidder != address(0)) {
            address lastBidder = auction.lastBidder;
            uint256 lastBidPrice = auction.heighestBid;

            // Transfer back to last bidder
            payToken.transfer(lastBidder, lastBidPrice);
        }

        _bidPlace(auction, _bidPrice);
    }

    function bidPlaceByETH(
        address _nft,
        uint256 _tokenId
    ) external payable isAuction(_nft, _tokenId) {
        uint256 _bidPrice = msg.value;
        require(
            block.timestamp >= auctionNfts[_nft][_tokenId].startTime,
            "auction not start"
        );
        require(
            block.timestamp <= auctionNfts[_nft][_tokenId].endTime,
            "auction ended"
        );
        require(
            _bidPrice >=
                auctionNfts[_nft][_tokenId].heighestBid +
                    auctionNfts[_nft][_tokenId].minBid,
            "less than min bid price"
        );

        AuctionNFT storage auction = auctionNfts[_nft][_tokenId];

        require(auction.payToken == address(0), "invalid pay token");

        if (auction.lastBidder != address(0)) {
            address lastBidder = auction.lastBidder;
            uint256 lastBidPrice = auction.heighestBid;

            // Transfer back to last bidder
            payable(lastBidder).transfer(lastBidPrice);
        }

        _bidPlace(auction, _bidPrice);
    }

    function _bidPlace(AuctionNFT storage auction, uint256 _bidPrice) internal {
        // Set new heighest bid price
        auction.lastBidder = msg.sender;
        auction.heighestBid = _bidPrice;

        emit PlacedBid(
            auction.nft,
            auction.tokenId,
            auction.payToken,
            _bidPrice,
            msg.sender
        );
    }

    // @notice Result auction, can call by auction creator, heighest bidder, or marketplace owner only!
    function resultAuction(address _nft, uint256 _tokenId) external {
        require(!auctionNfts[_nft][_tokenId].success, "already resulted");
        require(
            msg.sender == owner() ||
                msg.sender == auctionNfts[_nft][_tokenId].creator ||
                msg.sender == auctionNfts[_nft][_tokenId].lastBidder,
            "not creator, winner, or owner"
        );
        require(
            block.timestamp > auctionNfts[_nft][_tokenId].endTime,
            "auction not ended"
        );

        AuctionNFT storage auction = auctionNfts[_nft][_tokenId];
        IERC721 nft = IERC721(auction.nft);

        auction.success = true;
        auction.winner = auction.creator;

        uint256 heighestBid = auction.heighestBid;
        uint256 totalPrice = heighestBid;

        uint256 platformFeeTotal = calculatePlatformFee(heighestBid);

        if (auction.payToken == address(0)) {
            // Calculate & Transfer platfrom fee
            payable(feeRecipient).transfer(platformFeeTotal);
            // Transfer to auction creator
            payable(auction.creator).transfer(totalPrice - platformFeeTotal);
        } else {
            IERC20 payToken = IERC20(auction.payToken);
            // Calculate & Transfer platfrom fee
            payToken.transfer(feeRecipient, platformFeeTotal);

            // Transfer to auction creator
            payToken.transfer(auction.creator, totalPrice - platformFeeTotal);
        }

        // Transfer NFT to the winner
        nft.transferFrom(address(this), auction.lastBidder, auction.tokenId);

        emit ResultedAuction(
            _nft,
            _tokenId,
            auction.creator,
            auction.lastBidder,
            auction.heighestBid,
            msg.sender
        );
    }

    function calculatePlatformFee(
        uint256 _price
    ) public view returns (uint256) {
        return (_price * platformFee) / 10000;
    }

    function getListedNFT(
        address _nft,
        uint256 _tokenId
    ) public view returns (ListNFT memory) {
        return listNfts[_nft][_tokenId];
    }

    function getPayableTokens() external view returns (address[] memory) {
        return tokens;
    }

    function checkIsPayableToken(
        address _payableToken
    ) external view returns (bool) {
        return payableToken[_payableToken];
    }

    function addPayableToken(address _token) external onlyOwner {
        require(_token != address(0), "invalid token");
        require(!payableToken[_token], "already payable token");
        payableToken[_token] = true;
        tokens.push(_token);

        emit AddPayableToken(_token);
    }

    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        require(_platformFee <= 10000, "can't more than 10 percent");
        platformFee = _platformFee;
    }

    function changeFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "can't be 0 address");
        feeRecipient = _feeRecipient;
    }
}
