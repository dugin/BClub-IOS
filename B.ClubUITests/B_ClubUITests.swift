//
//  B_ClubUITests.swift
//  B.ClubUITests
//
//  Created by Bruno Gama on 24/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import XCTest

class B_ClubUITests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func waitFor(element:XCUIElement, seconds waitSeconds:Double) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(waitSeconds, handler: nil)
    }
    
    func waitAndAssert(element:XCUIElement, seconds waitSeconds:Double) {
        waitFor(element, seconds: waitSeconds)
        XCTAssert(element.exists)
    }
    
    func ss(name:String) {
        print("Screenshot \(name)")
        snapshot(name)
    }
    
    func testSnapshotsGenerator() {
        let query = "Patrícia Davidson"
        
        let app = XCUIApplication()
        let splashImage = app.images["splash_image"]
        waitAndAssert(splashImage, seconds: 1)
        ss("0_Launch")
        let cityChangeButton = app.buttons["cityFilterButton"]
        waitAndAssert(cityChangeButton, seconds: 3)
        ss("1_Home")
        app.navigationBars["B.Club"].buttons["UIBarButtonControl"].tap()
        ss("02_Filter")
        let tablesQuery = app.tables
        let searchField = tablesQuery.cells.textFields["Digite o que você procura"]
        waitAndAssert(searchField, seconds: 30)
        searchField.tap()
        searchField.typeText(query)
        tablesQuery.buttons["magnifiying"].tap()
//        let responseCell = tablesQuery.cells.staticTexts[query]
//        waitAndAssert(responseCell, seconds: 30)
        app.navigationBars["bclub"].buttons["B.Club"].tap()
        app.navigationBars["B.Club"].buttons["UIBarButtonMenu"].tap()
        ss("04_Login")
    }
}
