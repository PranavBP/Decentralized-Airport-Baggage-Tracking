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
        uint[] timestampHistory; //history of timestamp when scanned.
        BaggageStatus status;
    }

    address private boardingOfficial;
    address[] private baggageOfficials;

    Customer[] private customers;
    Baggage[] private baggage;

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

    function checkInBaggage(
        string[] memory baggageIds,
        string[] memory locations
    ) public {
        //Length of baggage IDs and their locations must be equal.
        require(baggageIds.length == locations.length);

        require(msg.sender == boardingOfficial);

        //Adds the baggage to the baggage array
        for (uint256 i = 0; i < baggageIds.length; i++) {
            Baggage memory b; 

            b.id = baggageIds[i];
            b.last_scanned_timestamp = block.timestamp;
            b.location = locations[i];
            b.status = BaggageStatus.CHECK_IN;

            baggage.push(b);

            baggageMapping[baggageIds[i]] = b;
        }
    }


    function addBaggageToSecurity(string memory baggageId, string memory location) public {
        require(baggageMapping[baggageId].status == BaggageStatus.CHECK_IN);

        uint timestamp = block.timestamp;

        baggageMapping[baggageId].status = BaggageStatus.SECURITY;
        baggageMapping[baggageId].last_scanned_timestamp = timestamp;

        //update the location and timestamp history
        baggageMapping[baggageId].locationHistory.push(location);
        baggageMapping[baggageId].timestampHistory.push(timestamp);
    }

    function addBaggageToBoarding(string memory baggageId, string memory location) public {
        require(baggageMapping[baggageId].status == BaggageStatus.SECURITY);

        uint timestamp = block.timestamp;

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

    function getBaggage() public view returns (Baggage[] memory) {
        return baggage;
    }
}
