// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BaggageTracker is ERC20{
    enum BaggageStatus {
        UNASSIGNED,
        CHECK_IN,
        SECURITY,
        BOARDED,
        ON_ROUTE,
        DELAYED
    }

    struct Baggage {
        string id;
        uint256 last_scanned_timestamp;
        string location;
        string[] locationHistory; //history of location when scanned.
        uint256[] timestampHistory; //history of timestamp when scanned.
        BaggageStatus status;
    }

    address private boardingOfficial;
    address[] private baggageOfficials;

    mapping(string => Baggage) private baggageMapping;
    mapping(address => string) private customers;

    //The baggage official is allowed to create a new contract, providing the list of customers as the input
    constructor() ERC20("Baggagely", "BGLY"){
        boardingOfficial = msg.sender;
    }

    function addCustomer(string memory id) public {
        customers[msg.sender] = id;
        _mint(msg.sender, 100);
    }

    function isCustomer() public view returns (bool) {
        bytes memory id_bytes = bytes(customers[msg.sender]);

        if(id_bytes.length == 0){
            return false;
        }

        return true;
    }

    function checkInBaggage(string memory baggageId, string memory location)
        public
    {
        bool _isBaggageOfficial = false;

        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (baggageOfficials[i] == msg.sender) {
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);
        require(baggageMapping[baggageId].status == BaggageStatus.UNASSIGNED);

        uint256 timestamp = block.timestamp;

        //Initialize and add a new bag to the baggage array
        Baggage memory b;

        b.id = baggageId;
        b.last_scanned_timestamp = timestamp;
        b.location = location;
        b.status = BaggageStatus.CHECK_IN;

        baggageMapping[baggageId] = b;

        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function addBaggageToSecurity(string memory baggageId, string memory location) public {
        bool _isBaggageOfficial = false;

        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (baggageOfficials[i] == msg.sender) {
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);

        require(baggageMapping[baggageId].status == BaggageStatus.CHECK_IN);

        uint256 timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.SECURITY;
        baggageMapping[baggageId].last_scanned_timestamp = timestamp;

        //update the location and timestamp history
        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function addBaggageToBoarding(
        string memory baggageId,
        string memory location
    ) public {
        bool _isBaggageOfficial = false;

        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (baggageOfficials[i] == msg.sender) {
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);

        require(baggageMapping[baggageId].status == BaggageStatus.SECURITY);

        uint256 timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.BOARDED;
        baggageMapping[baggageId].last_scanned_timestamp = timestamp;

        //update the location and timestamp history.
        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function addBaggageToOnRoute(
        string memory baggageId,
        string memory location
    ) public {
        bool _isBaggageOfficial = false;

        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (baggageOfficials[i] == msg.sender) {
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);

        require(
            baggageMapping[baggageId].status == BaggageStatus.BOARDED ||
                baggageMapping[baggageId].status == BaggageStatus.ON_ROUTE
        );

        uint256 timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.ON_ROUTE;
        baggageMapping[baggageId].last_scanned_timestamp = timestamp;

        //update the location and timestamp history.
        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function addBaggageToDelayed(
        string memory baggageId,
        string memory location
    ) public {
        bool _isBaggageOfficial = false;

        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (baggageOfficials[i] == msg.sender) {
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);

        uint256 timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.DELAYED;
        baggageMapping[baggageId].last_scanned_timestamp = timestamp;

        //update the location and timestamp history.
        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function isBoardingOfficial() public view returns (bool) {
        if (msg.sender == boardingOfficial) {
            return true;
        }
        return false;
    }

    function isBaggageOfficial() public view returns (bool) {
        for (uint256 i = 0; i < baggageOfficials.length; i++) {
            if (msg.sender == baggageOfficials[i]) {
                return true;
            }
        }

        return false;
    }

    function assignBaggageOfficial(address[] memory officials) public {
        require(msg.sender == boardingOfficial);
        for (uint256 i = 0; i < officials.length; i++) {
            baggageOfficials.push(officials[i]);
        }
    }

    function getBaggageStatus(string memory baggageId)
        public
        view
        returns (BaggageStatus)
    {
        return baggageMapping[baggageId].status;
    }

    function getBaggage(string memory baggageId)
        public
        view
        returns (Baggage memory)
    {
        return baggageMapping[baggageId];
    }

    function getCustomerId() public view returns(string memory){
        return customers[msg.sender];
    }

    function getBalance() public view returns(uint){
        return balanceOf(msg.sender);
    }

    function reward(uint amount) public payable {
        require(isCustomer());
        require(balanceOf(msg.sender) >= amount);

        uint reward_chunk = uint(amount) / uint((baggageOfficials.length + 1));

        transfer(boardingOfficial, reward_chunk);

        for(uint i = 0; i<baggageOfficials.length; i++){
            transfer(baggageOfficials[i], reward_chunk);
        }
    }
}
