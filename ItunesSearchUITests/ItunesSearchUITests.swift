import XCTest

final class ItunesSearchUITests: XCTestCase {
    
    func test_WhenSearchQuery_ThenAppsArePresented_WhenSelectedApp_ThenAppDetailsIsDisplayed() {
        let app = XCUIApplication()
        app.launch()
        
        // Search "itunes"
        app.searchFields.element.tap()
        app.typeText("itunes")
        app.typeText("\n")
        
        // Verify results are present
        let table = app.tables.matching(identifier: "app.search.tableView")
        let cell = table.cells.element(matching: .cell, identifier: "app.search.result_0")
        XCTAssertNotNil(cell.staticTexts.matching(identifier: "app.search.result_0.appName"))
        
        // Navigate to details
        cell.tap()
        
        // Verify that details title is displayed
        XCTAssertNotNil(app.staticTexts.matching(identifier: "app.details.appName"))
    }
}
