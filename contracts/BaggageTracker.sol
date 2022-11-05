// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract BaggageTracker {
    enum CustomerStatus {
        BOARDED,
        CHECKIN
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
        BaggageStatus status;
    }

    address private baggageOfficial;

    Customer[] private customers;
    Baggage[] private baggage;

    mapping (string => Baggage) private baggageMapping;

    //The baggage official is allowed to create a new contract, providing the list of customers as the input
    constructor(string[] memory customer_ids) {
        baggageOfficial = msg.sender;

        //Initialize the list of customers for this journey
        for (uint256 i = 0; i < customer_ids.length; i++) {
            customers.push(
                Customer({id: customer_ids[i], status: CustomerStatus.CHECKIN})
            );
        }
    }

    function checkInBaggage(
        string[] memory baggageIds,
        string[] memory locations
    ) public {

        //Length of baggage IDs and their locations must be equal.
        require(baggageIds.length == locations.length);


        //Adds the baggage to the baggage array
        for (uint256 i = 0; i < baggageIds.length; i++) {

            Baggage memory b = Baggage({
                    id: baggageIds[i],
                    last_scanned_timestamp: block.timestamp,
                    location: locations[i],
                    status: BaggageStatus.CHECK_IN
                });

            baggage.push(b);

            baggageMapping[baggageIds[i]] = b;
        }
    }

    function addBaggageToSecurity(string memory baggageId) public {

        baggageMapping[baggageId].status = BaggageStatus.SECURITY;
        baggageMapping[baggageId].last_scanned_timestamp = block.timestamp;
    }

    function getCustomers() public view returns (Customer[] memory) {
        return customers;
    }

    function getBaggage() public view returns (Baggage[] memory) {
        return baggage;
    }
}
