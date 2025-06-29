import Foundation
import CoreData

@objc(AppItem)
public class AppItem: NSManagedObject {
    
    // MARK: - Convenience Initializer
    convenience init(from appResult: AppResult, context: NSManagedObjectContext) {
        self.init(context: context)
        self.trackName = appResult.trackName
        self.trackId = Int64(appResult.trackId)
        self.artistName = appResult.artistName
        self.artworkUrl100 = appResult.artworkUrl100
        self.averageUserRating = appResult.averageUserRating ?? 0.0
        self.userRatingCount = Int32(appResult.userRatingCount ?? 0)
        self.primaryGenreName = appResult.primaryGenreName
        self.formattedPrice = appResult.formattedPrice ?? ""
        self.trackDescription = appResult.description
        self.screenshotUrls = appResult.screenshotUrls
        self.trackContentRating = appResult.trackContentRating
        self.minimumOsVersion = minimumOsVersion
        self.searchQuery = "" // Will be set by the caller
        self.dateAdded = Date()
    }
    
    // MARK: - Convert to AppResult
    func toAppResult() -> AppResult {
        return AppResult(
            trackId: Int(trackId),
            trackName: trackName,
            artistName: artistName,
            artworkUrl100: artworkUrl100,
            averageUserRating: averageUserRating,
            userRatingCount: Int(userRatingCount),
            primaryGenreName: primaryGenreName,
            formattedPrice: formattedPrice,
            description: trackDescription,
            screenshotUrls: screenshotUrls,
            trackContentRating: trackContentRating,
            minimumOsVersion: minimumOsVersion
        )
    }
}
