import XCTest
import CoreData
@testable import ItunesSearch

class CoreDataManagerTests: XCTestCase {

    var sut: CoreDataManager!
    var mockPersistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        mockPersistentContainer = createMockPersistentContainer()
        sut = CoreDataManager(persistentContainer: mockPersistentContainer)
    }

    override func tearDown() {
        sut = nil
        mockPersistentContainer = nil
        super.tearDown()
    }

    func testGivenAppsToSave_WhenSUTSaveApps_ThenAppsAreSaved() throws {
        // Given
        let query = "new apps"
        let appsToSave = [
            AppResult.mock(),
            AppResult.mock()
        ]

        // When
        try sut.saveApps(appsToSave, for: query)

        // Then
        let fetchedApps = try sut.fetchApps(for: query)
        XCTAssertEqual(fetchedApps.count, 2, "Should have saved 2 apps.")
        XCTAssertTrue(fetchedApps.contains(appsToSave[0]))
        XCTAssertTrue(fetchedApps.contains(appsToSave[1]))
    }

    func testGivenSavedAppsForQuery_WhenNeAppsAreSavedForTheSameQuery_ThenNewAppsReplaceInitialApps() throws {
        // Given
        let query = "existing apps"
        let initialApps = [
            AppResult.mock(trackId: 1)
        ]
        try sut.saveApps(initialApps, for: query)

        let newApps = [
            AppResult.mock(trackId: 2),
            AppResult.mock(trackId: 3)
        ]
        // When
        try sut.saveApps(newApps, for: query) // This should replace the old app

        // Then
        let fetchedApps = try sut.fetchApps(for: query)
        XCTAssertEqual(fetchedApps.count, 2, "Should have replaced old apps with 2 new apps.")
        XCTAssertTrue(fetchedApps.contains(newApps[0]))
        XCTAssertTrue(fetchedApps.contains(newApps[1]))
        XCTAssertFalse(fetchedApps.contains(initialApps[0])) // Ensure old app is gone
    }

    func testGivenEmptyAppsSaved_WhenSaveApps_ThenEmptyArrayIsSaved() throws {
        // Given
        let query = "empty query"
        let appsToSave: [AppResult] = []

        // When
        try sut.saveApps(appsToSave, for: query)

        // Then
        let fetchedApps = try sut.fetchApps(for: query)
        XCTAssertTrue(fetchedApps.isEmpty, "Saving an empty array should result in no apps for that query.")
    }

    func testGivenApps_WhenSUTSaveAppsWithLowerCaseQuery_ThenUpperCaseQueryReturnsCorrectResults_GivenNewApps_WhenSUTSaveAppsWithUpperCaseQuery_ThenLowerCaseQueryReturnsCorrectResults() throws {
        // Given
        let queryLower = "test query"
        let queryUpper = "TEST QUERY"
        let apps = [AppResult.mock(trackId: 1)]

        // When
        try sut.saveApps(apps, for: queryLower)
        
        // Then
        let fetchedAppsUpper = try sut.fetchApps(for: queryUpper)
        XCTAssertEqual(fetchedAppsUpper.count, 1, "Should fetch apps regardless of query case.")

        // Given
        // Verify replacing works with different case
        let newApps = [AppResult.mock(trackId: 2)]
        
        // When
        try sut.saveApps(newApps, for: queryUpper)
        
        // Then
        let fetchedAppsLower = try sut.fetchApps(for: queryLower)
        XCTAssertEqual(fetchedAppsLower.count, 1, "Should replace apps regardless of query case.")
        XCTAssertTrue(fetchedAppsLower.contains(newApps[0]))
    }

    func testGivenApps_WhenSUTSavesUsingDifferentQueries_ThenCorrectValuesAreReturnedForQueries() throws {
        // Given
        let query1 = "query one"
        let apps1 = [AppResult.mock(trackId: 1)]

        let query2 = "query two"
        let apps2 = [AppResult.mock(trackId: 2),
                     AppResult.mock(trackId: 3)]
        // When
        try sut.saveApps(apps1, for: query1)
        try sut.saveApps(apps2, for: query2)

        // Then
        let fetchedAppsForQuery1 = try sut.fetchApps(for: query1)
        XCTAssertEqual(fetchedAppsForQuery1.count, 1)
        XCTAssertTrue(fetchedAppsForQuery1.contains(apps1[0]))

        let fetchedAppsForQuery2 = try sut.fetchApps(for: query2)
        XCTAssertEqual(fetchedAppsForQuery2.count, 2)
        XCTAssertTrue(fetchedAppsForQuery2.contains(apps2[0]))
        XCTAssertTrue(fetchedAppsForQuery2.contains(apps2[1]))
    }

    func testGivenNoSavedApps_WhenSUTFetchApps_ThenNoResultsAreReturned() throws {
        // When
        let nonExistentQuery = "non existent"
        let fetchedApps = try sut.fetchApps(for: nonExistentQuery)
        
        // Then
        XCTAssertTrue(fetchedApps.isEmpty, "Should return an empty array for a non-existent query.")
    }

    func testGivenSavedApps_WhenSUTDeleteOldApps_ThenOnlyOldAppIsDeleted() throws {
        let queryRecent = "recent_query"
        let recentApp = AppResult.mock(trackId: 2)
        try sut.saveApps([recentApp], for: queryRecent) // dateAdded will be now

        let context = mockPersistentContainer.viewContext

        let oldAppDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let oldAppItem = AppItem(context: context)
        oldAppItem.trackId = 999
        oldAppItem.trackName = "Old App"
        oldAppItem.artistName = "O"
        oldAppItem.artworkUrl100 = "OldartworkUrl100"
        oldAppItem.minimumOsVersion = "1.0"
        oldAppItem.primaryGenreName = "primaryGenreName"
        oldAppItem.screenshotUrls = ["screenshotUrls"]
        oldAppItem.trackContentRating = "trackContentRating"
        oldAppItem.trackDescription = "trackDescription"
        oldAppItem.searchQuery = "old_query"
        oldAppItem.dateAdded = oldAppDate

        try context.save()

        // Verify old app exists initially
        let initialOldAppsFetchRequest: NSFetchRequest<AppItem> = AppItem.fetchRequest()
        initialOldAppsFetchRequest.predicate = NSPredicate(format: "trackId == %ld", 999)
        let initialOldAppItems = try context.fetch(initialOldAppsFetchRequest)
        XCTAssertEqual(initialOldAppItems.count, 1, "Old app should exist before deletion.")

        try sut.deleteOldApps(olderThan: 5)

        // Verify old app is deleted
        let afterDeleteOldApps = try context.fetch(initialOldAppsFetchRequest)
        XCTAssertTrue(afterDeleteOldApps.isEmpty, "Old app should be deleted.")

        // Verify recent app is still there
        let fetchedRecentApps = try sut.fetchApps(for: queryRecent)
        XCTAssertEqual(fetchedRecentApps.count, 1, "Recent app should not be deleted.")
        XCTAssertTrue(fetchedRecentApps.contains(recentApp))
    }

    func testGivenSavedApps_WhenSUTDeleteOldApps_doesNotDeleteRecentApps() throws {
        // Given
        let query = "recent_apps"
        let app1 = AppResult.mock(trackId: 1)
        let app2 = AppResult.mock(trackId: 2)
        try sut.saveApps([app1, app2], for: query) // dateAdded will be now

        let initialCount = try sut.fetchApps(for: query).count
        XCTAssertEqual(initialCount, 2)

        // When
        try sut.deleteOldApps(olderThan: 1)

        // Then
        let fetchedApps = try sut.fetchApps(for: query)
        let finalCount = fetchedApps.count
        XCTAssertEqual(finalCount, 2, "Recent apps should not be deleted.")
        XCTAssertTrue(fetchedApps.contains(app1))
        XCTAssertTrue(fetchedApps.contains(app2))
        XCTAssertEqual(finalCount, initialCount, "No apps should be deleted if none are old enough.")
    }

    func testGivenNoSavedApps_WhenSUTDeleteOldApps_ThenNoAppsAreReturned() throws {
        // When
        try sut.deleteOldApps(olderThan: 1)

        // Then
        let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
        let allAppItems = try mockPersistentContainer.viewContext.fetch(request)
        XCTAssertTrue(allAppItems.isEmpty, "No apps should exist after trying to delete from empty store.")
    }
    
    func createMockPersistentContainer() -> NSPersistentContainer {
        // Load the managed object model from the main bundle (where your .xcdatamodeld resides)
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main]) else {
            fatalError("Could not load managed object model")
        }

        let container = NSPersistentContainer(name: "ItunesSearch", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        return container
    }
}
