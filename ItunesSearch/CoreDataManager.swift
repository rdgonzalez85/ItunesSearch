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
        
        try context.performAndWait {
            // Delete existing apps for this query to avoid duplicates
            do {
                try self.deleteApps(for: query, in: context)
            } catch {
                throw CoreDataError.deletionFailed(error.localizedDescription) // Wrap specific error
            }
            
            // Create new AppItem objects
            for app in apps {
                let appItem = AppItem(from: app, context: self.context)
                appItem.searchQuery = query.lowercased()
            }
            
            // Save context
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    // It's good practice to log or handle the error more specifically
                    self.context.rollback() // Rollback changes if save fails
                    throw CoreDataError.saveFailed(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchApps(for query: String) throws -> [AppResult] {
        var fetchedResults: [AppResult] = []
        var fetchError: Error?
        
        context.performAndWait {
            let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
            request.predicate = NSPredicate(format: "searchQuery == %@", query.lowercased())
            request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
            
            do {
                let appItems = try self.context.fetch(request)
                fetchedResults = appItems.map { $0.toAppResult() }
            } catch {
                fetchError = CoreDataError.fetchFailed(error.localizedDescription)
            }
        }
        
        if let error = fetchError {
            throw error
        }
        return fetchedResults
    }

    private func deleteApps(for query: String, in context: NSManagedObjectContext) throws {
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
            throw CoreDataError.invalidDateCalculation("Could not determine cutoff date.")
        }
        
        try context.performAndWait {
            let request: NSFetchRequest<AppItem> = AppItem.fetchRequest()
            request.predicate = NSPredicate(format: "dateAdded < %@", cutoffDate as NSDate)
            
            do {
                let oldAppItems = try self.context.fetch(request)
                for appItem in oldAppItems {
                    self.context.delete(appItem)
                }
                
                if self.context.hasChanges {
                    try self.context.save()
                }
            } catch {
                self.context.rollback()
                throw CoreDataError.deletionFailed(error.localizedDescription)
            }
        }
    }
}

enum CoreDataError: Error, LocalizedError {
    case saveFailed(String)
    case fetchFailed(String)
    case deletionFailed(String)
    case invalidDateCalculation(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let message): return "Failed to save data: \(message)"
        case .fetchFailed(let message): return "Failed to fetch data: \(message)"
        case .deletionFailed(let message): return "Failed to delete data: \(message)"
        case .invalidDateCalculation(let message): return "Date calculation error: \(message)"
        case .unknown(let message): return "An unknown Core Data error occurred: \(message)"
        }
    }
}
