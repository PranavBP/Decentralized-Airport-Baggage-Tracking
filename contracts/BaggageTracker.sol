// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BaggageTracker {
    enum CustomerStatus {
        CHECKIN,
        BOARDED
    }
    enum BaggageStatus {
        CHECK_IN,
        SECURITY,
        BOARDED,
        DELAYED
    }

    struct Customer {
        string id;
        CustomerStatus status;
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

    Customer[] private customers;
    mapping(string => Baggage) private baggageMapping;

    //The baggage official is allowed to create a new contract, providing the list of customers as the input
    constructor(string[] memory customer_ids) {
        boardingOfficial = msg.sender;

        //Initialize the list of customers for this journey
        for (uint256 i = 0; i < customer_ids.length; i++) {
            customers.push(
                //Customer({id: customer_ids[i], status: CustomerStatus.CHECKIN})
                Customer(customer_ids[i], CustomerStatus.CHECKIN)
            );
        }
    }

    function checkInBaggage(string memory baggageId, string memory location)
        public
    {
        bool _isBaggageOfficial = false;

        for (uint i = 0; i < baggageOfficials.length; i++){
            if (baggageOfficials[i] == msg.sender){
                _isBaggageOfficial = true;
            }
        }

        require(_isBaggageOfficial);

        //Initialize and add a new bag to the baggage array
        Baggage memory b;

        b.id = baggageId;
        b.last_scanned_timestamp = block.timestamp;
        b.location = location;
        b.status = BaggageStatus.CHECK_IN;

        baggageMapping[baggageId] = b;
    }

    function addBaggageToSecurity(
        string memory baggageId,
        string memory location
    ) public {
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
        require(baggageMapping[baggageId].status == BaggageStatus.SECURITY);

        uint256 timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.BOARDED;
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

    function getCustomers() public view returns (Customer[] memory) {
        return customers;
    }

    function getBaggage(string memory baggageId) public view returns (Baggage memory) {
        return baggageMapping[baggageId];
    }
}
