//
//

import Foundation
import CoreData


extension AppItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppItem> {
        return NSFetchRequest<AppItem>(entityName: "AppItem")
    }

    @NSManaged public var artistName: String
    @NSManaged public var artworkUrl100: String
    @NSManaged public var averageUserRating: Double
    @NSManaged public var dateAdded: Date
    @NSManaged public var formattedPrice: String?
    @NSManaged public var primaryGenreName: String
    @NSManaged public var searchQuery: String
    @NSManaged public var trackName: String
    @NSManaged public var trackId: Int64
    @NSManaged public var userRatingCount: Int32
    @NSManaged public var trackDescription: String
    @NSManaged public var screenshotUrls: [String]
    @NSManaged public var trackContentRating: String
    @NSManaged public var minimumOsVersion: String

}

extension AppItem : Identifiable {

}
