import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func saveApps(_ apps: [AppResult], for query: String) throws
    func fetchApps(for query: String) throws -> [AppResult]
    func deleteOldApps(olderThan days: Int) throws
}

class CoreDataManager: CoreDataManagerProtocol {
    
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Apps
    func saveApps(_ apps: [AppResult], for query: String) throws {
        let context = self.context
        
        // Delete existing apps for this query to avoid duplicates
        try deleteApps(for: query)
        
        // Create new AppItem objects
        for app in apps {
            let appItem = AppItem(from: app, context: context)
            appItem.searchQuery = query.lowercased()
        }
        
        // Save context
        if context.hasChanges {
            try context.save()
        }
    }
    
    func fetchApps(for query: String) throws -> [AppResult] {
        let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
        request.predicate = NSPredicate(format: "searchQuery == %@", query.lowercased())
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        let appItems = try context.fetch(request)
        return appItems.map { $0.toAppResult() }
    }
    
    private func deleteApps(for query: String) throws {
        let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
        request.predicate = NSPredicate(format: "searchQuery == %@", query.lowercased())
        
        let appItems = try context.fetch(request)
        for appItem in appItems {
            context.delete(appItem)
        }
    }
    
    func deleteOldApps(olderThan days: Int) throws {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return
        }
        
        let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
        request.predicate = NSPredicate(format: "dateAdded < %@", cutoffDate as NSDate)
        
        let oldAppItems = try context.fetch(request)
        for appItem in oldAppItems {
            context.delete(appItem)
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
}
