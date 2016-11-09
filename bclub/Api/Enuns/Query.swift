//
//  Query.swift
//  BackendlessApiControllerAdventures
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 Bruno Gama. All rights reserved.
//

// MARK: - BackendlessDataQuery Generation -


protocol DataQuery {
    var MAX_PAGE_SIZE:Int { get }
    var dataQuery : BackendlessDataQuery { get }
}

enum Query {
    case CpfSearch(String)
    case EmailSearch(String)
    case UserBuiltSearch(SearchParameters)
    case CitySearch(String)
    case OrdinaryPromotionsForCity(String)
    case OrdinaryPromotionsForCityId(String)
    case FeaturedPromotionsForCityId(String, NSDate)
    case VoucherSearch(String, String)
    case UserWithId(String)
    case Categories()
    case CitiesWithSubstring(String)
}

extension Query : DataQuery {
    var MAX_PAGE_SIZE:Int {
        get {
            return 50
        }
    }
    
    var dataQuery : BackendlessDataQuery {
        let backendlessDataQuery = BackendlessDataQuery()
        switch self {
            
        case CpfSearch(let cpf):
            backendlessDataQuery.whereClause = Where.CpfSearch(cpf).query
        
        case .EmailSearch(let email):
            backendlessDataQuery.whereClause = Where.EmailSearch(email).query
        
        case .UserBuiltSearch(let searchParameters):
            backendlessDataQuery.whereClause = Where.UserBuiltSearch(searchParameters).query
            backendlessDataQuery.queryOptions = queryOptions()
        
        case CitySearch(let city):
            backendlessDataQuery.whereClause = Where.CitySearch(city).query
            
        case OrdinaryPromotionsForCity(let city):
            backendlessDataQuery.whereClause = Where.OrdinaryPromotionsForCity(city).query
            backendlessDataQuery.queryOptions = queryOptions()
            
        case OrdinaryPromotionsForCityId(let cityId):
            backendlessDataQuery.whereClause = Where.OrdinaryPromotionsForCityId(cityId).query
            backendlessDataQuery.queryOptions = queryOptions()
        
        case FeaturedPromotionsForCityId(let cityId, let date):
            backendlessDataQuery.whereClause = Where.FeaturedPromotionsForCityId(cityId, date).query
            backendlessDataQuery.queryOptions = queryOptions()
            backendlessDataQuery.queryOptions.pageSize = 1
            
        case VoucherSearch(let email, let voucher):
            backendlessDataQuery.whereClause = Where.VoucherSearch(email, voucher).query
            
        case UserWithId(let objectId):
            backendlessDataQuery.whereClause = Where.UserWithId(objectId).query
            let options = QueryOptions()
            options.relationsDepth = 1
            options.addRelated("subscriptionPayment")
            options.addRelated("voucher")
            
        case Categories():
            let options = QueryOptions()
            options.relationsDepth = 1
            options.pageSize = MAX_PAGE_SIZE
            backendlessDataQuery.queryOptions = options
            
        case CitiesWithSubstring(let substring):
            backendlessDataQuery.whereClause = Where.CitiesWithSubstring(substring).query
            let options = QueryOptions()
            options.relationsDepth = 1
            options.pageSize = MAX_PAGE_SIZE
            backendlessDataQuery.queryOptions = options
            
        }
        
        return backendlessDataQuery
    }
    
    private func queryOptions() -> QueryOptions {
        let options = QueryOptions()
        options.relationsDepth = 3
        options.pageSize = MAX_PAGE_SIZE
        options.addRelated("promotions")
        options.addRelated("establishment")
        options.addRelated("establishment.category")
        options.addRelated("establishment.address")
        options.addRelated("establishment.address.neighborhood")
        return options
    }
}

// MARK: - Where Query String Generation -

protocol QueryComposerProtocol {
    var query : String { get }
}

enum Where {
    case CpfSearch(String)
    case EmailSearch(String)
    case CitySearch(String)
    case UserBuiltSearch(SearchParameters)
    case UserBuiltSearchByCity(SearchParameters)
    case UserBuiltSearchByCategories(SearchParameters)
    case UserBuiltSearchByDiscount(SearchParameters)
    case UserBuiltSearchByUserInput(SearchParameters)
    case UserBuiltSearchByWeekdays(SearchParameters)
    case OrdinaryPromotionsForCity(String)
    case OrdinaryPromotionsForCityId(String)
    case FeaturedPromotionsForCityId(String, NSDate)
    case VoucherSearch(String, String)
    case UserWithId(String)
    case CitiesWithSubstring(String)

}

extension Where : QueryComposerProtocol {
    var query: String {
        var _query = ""
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        switch self {
            
        case CpfSearch(let cpf):
            _query = "cpf = '\(cpf)'"

        case EmailSearch(let email):
            _query = "email = '\(email)'"
            
        case .UserBuiltSearch(let searchParameters):
            let whereList = [Where.UserBuiltSearchByCity(searchParameters).query,
                             Where.UserBuiltSearchByCategories(searchParameters).query,
                             Where.UserBuiltSearchByDiscount(searchParameters).query,
                             Where.UserBuiltSearchByUserInput(searchParameters).query,
                             Where.UserBuiltSearchByWeekdays(searchParameters).query]
            _query = "active = true and featuredDate is null "
            _query += whereList.map{ $0 }.joinWithSeparator(" ")
            
        case CitySearch(let city):
            _query = "name = '\(city)'"
            
        case UserBuiltSearchByCity(let searchParameters):
            if searchParameters.city != Constants.Strings.allCities && !searchParameters.city.isEmpty {
                _query = " AND establishment.address.neighborhood.city.objectId = '\(searchParameters.city)'"
            }
            
        case UserBuiltSearchByCategories(let searchParameters):
            if searchParameters.establishmentCategories.count > 0 {
                let queryParameters = searchParameters.establishmentCategories.map{ "'\($0.objectId)'" }.joinWithSeparator(", ")
                _query = " AND establishment.category.objectId in (\(queryParameters))"
            }
            
        case UserBuiltSearchByDiscount(let searchParameters):
            if searchParameters.discountList.count > 0 {
                let queryParameters = searchParameters.discountList.sort().map{ "'\($0)'" }.joinWithSeparator(", ")
                _query = " AND promotions.percent in (\(queryParameters))"
            }
            
        case UserBuiltSearchByUserInput(let searchParameters):
            if !searchParameters.inputString.isEmpty {
                _query = " AND establishment.name LIKE '%\(searchParameters.inputString)%'"
            }
            
        case UserBuiltSearchByWeekdays(let searchParameters):
            if searchParameters.weekdays.count > 0 {
                var query = " AND ("
                let weekdays = searchParameters.weekdays.map { "promotions.\(dateFormatter.weekdaySymbols[$0].lowercaseString)" }
                query +=  weekdays.joinWithSeparator(" is not null OR ")
                if weekdays.count == 1 {
                    query += " is not null"
                }
                query += ")"
                _query = query
            }
            
        case OrdinaryPromotionsForCity(let city):
            _query = "active = true and featuredDate is null"
            if !city.isEmpty {
                _query += " and establishment.address.neighborhood.city.name = '\(city)'"
            }
            
        case OrdinaryPromotionsForCityId(let cityId):
            if !cityId.isEmpty {
                _query = "active = true and featuredDate is null and establishment.address.neighborhood.city.objectId = '\(cityId)'"
            }
            else {
                _query = "active = true and featuredDate is null"
            }
            
        case FeaturedPromotionsForCityId(let cityId, let date):
            if !cityId.isEmpty {
                _query = "active = true and featuredDate >= '\(dateFormatter.stringFromDate(date))' and establishment.address.neighborhood.city.objectId = '\(cityId)'"
            }
            else {
                _query = "active = true and featuredDate >= '\(dateFormatter.stringFromDate(date))'"
            }
            
        
        case VoucherSearch(let email, let voucher):
            if email.isEmpty {
                _query = "name = '\(voucher)' AND used = false"
            }
            else {
                _query = "name = '\(voucher)' AND email = '\(email)' AND used = false"
            }
            
        case UserWithId(let objectId):
            _query = "objectId = '\(objectId)'"
            
        case CitiesWithSubstring(let substring):
            _query = "name LIKE '\(substring)%'"
        }
    
        return _query
    }
}
