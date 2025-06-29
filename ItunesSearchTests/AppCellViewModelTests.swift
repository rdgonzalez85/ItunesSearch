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
        let userRatingFormatter = MockUserRatingFormatter()
        let viewModel = AppCellViewModel(app: appResult, reviewFormatter: userRatingFormatter)
        
        XCTAssertEqual(viewModel.ratingText, String(format: "%.1f ⭐ \(viewModel.ratingCount)", viewModel.rating))
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
    static func mock(trackId: Int = 1, userRatingCount: Int = 10) -> AppResult {
        AppResult(
            trackId: trackId,
            trackName: "trackName",
            artistName: "artistName",
            artworkUrl100: "artworkUrl100",
            averageUserRating: 5.0,
            userRatingCount: userRatingCount,
            primaryGenreName: "primaryGenreName",
            formattedPrice: "1.0",
            description: "description",
            screenshotUrls: [],
            trackContentRating: "",
            minimumOsVersion: ""
        )
    }
}
