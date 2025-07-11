import Foundation

struct SearchResponse: Codable {
    let resultCount: Int
    let results: [AppResult]
}

struct AppResult: Codable, Equatable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: String
    let averageUserRating: Double?
    let userRatingCount: Int?
    let primaryGenreName: String
    let formattedPrice: String?
    let description: String
    let screenshotUrls: [String]
    let trackContentRating: String
    let minimumOsVersion: String
}
