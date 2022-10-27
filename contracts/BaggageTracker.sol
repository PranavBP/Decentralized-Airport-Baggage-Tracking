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
        BaggageStatus status;
    }

    address private baggageOfficial;

    Customer[] private customers;
    Baggage[] private baggage;

    constructor(string[] memory customer_ids) {
        baggageOfficial = msg.sender;

        //Initialize the list of customers for this journey
        for (uint256 i = 0; i < customer_ids.length; i++) {
            customers.push(
                Customer({id: customer_ids[i], status: CustomerStatus.CHECKIN})
            );
        }
    }

    function getCustomers() public view returns (Customer[] memory) {
        return customers;
    }

    function getBaggage() public view returns (Baggage[] memory) {
        return baggage;
    }
}
