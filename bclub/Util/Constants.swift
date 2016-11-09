//
//  Constants.swift
//  bclub
//
//  Created by Bruno Gama on 24/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

struct Constants {
    struct Backendless {
        static let AppplicationId = "6EBD10E2-F126-8686-FFE2-92665224C200"
        static let IosScretKey    = "A26BCD96-0D5B-2D1D-FF16-A03C4CD1BC00"
        static let Version        = "v1"
    }
    
    struct Stripe {
        struct Develop {
            static let Key = "pk_test_XLUgCIsHtBQtHa9bZBVKKI7q"
        }
        
        struct Production {
            static let Key = "pk_live_yOjCb65RKhc5uUuNPh0q87xq"
        }
    }
    
    struct Strings {
        static let allCities = "Todas as cidades"
    }
    
    struct GlobalSegues {
        static let cityFilter = "CityFilter"
    }
    
    struct KeychainAccess {
        static let Service = "B.Club.KeychainAccess.Service"
        static let UserId = "B.Club.KeychainAccess.UserId"
        static let Email = "B.Club.KeychainAccess.Email"
    }
    
    struct Notifications {
        static let backFromFilter = "backFromFilter"        
    }
}