import XCTest
@testable import ItunesSearch

final class AppCellViewModelTests: XCTestCase {

    func testGivenAppResult_WhenAppCellViewModelIsCreated_ThenCorrectValuesAreAssigned() {
        let appResult = AppResult.mock()
        let viewModel = AppCellViewModel(app: appResult)
        
        XCTAssertTrue(viewModel.isEqualTo(appResult))
    }
    
    func testGivenAppResult_WhenAppCellViewModelIsCreated_ThenRatingTextReturnsTheCorrectValue() {
        
        let appResult = AppResult.mock()
        let viewModel = AppCellViewModel(app: appResult)
        
        XCTAssertEqual(viewModel.ratingText, String(format: "%.1f ⭐ \(viewModel.formattedRatingCount)", viewModel.rating))
    }

    func testGivenAppResultWithUserRatingCount_WhenAppCellViewModelIsCreated_ThenFormattedRatingCountReturnsTheCorrectValue() {
        var appResult = AppResult.mock(userRatingCount: 1213310) // 1,213,310
        var viewModel = AppCellViewModel(app: appResult)
        
        XCTAssertEqual(viewModel.formattedRatingCount, "1.2M ratings")
        
        appResult = AppResult.mock(userRatingCount: 213310) // 213,310
        viewModel = AppCellViewModel(app: appResult)
        XCTAssertEqual(viewModel.formattedRatingCount, "213.3K ratings")
        
        appResult = AppResult.mock(userRatingCount: 310)
        viewModel = AppCellViewModel(app: appResult)
        XCTAssertEqual(viewModel.formattedRatingCount, "310 ratings")
        
        appResult = AppResult.mock(userRatingCount: 0)
        viewModel = AppCellViewModel(app: appResult)
        XCTAssertEqual(viewModel.formattedRatingCount, "No ratings")
    }
}

extension AppCellViewModel {
    func isEqualTo(_ app: AppResult) -> Bool {
        appName == app.trackName &&
        developerName == app.artistName &&
        category == app.primaryGenreName &&
        price == app.formattedPrice &&
        rating == app.averageUserRating &&
        ratingCount == app.userRatingCount &&
        iconURL == app.artworkUrl100
    }
}

extension AppResult {
    static func mock(userRatingCount: Int = 10) -> AppResult {
        AppResult(
            trackId: 1,
            trackName: "trackName",
            artistName: "artistName",
            description: "description",
            artworkUrl100: "artworkUrl100",
            averageUserRating: 5.0,
            userRatingCount: userRatingCount,
            primaryGenreName: "primaryGenreName",
            formattedPrice: "1.0",
            trackViewUrl: "trackViewUrl")
    }
}
