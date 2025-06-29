import Foundation
@testable import ItunesSearch

class MockCoreDataManager: CoreDataManagerProtocol {

    // MARK: - Properties to track calls

    /// An array to store the apps and queries passed to `saveApps`.
    /// Each element is a tuple `(apps: [AppResult], query: String)`.
    var saveAppsCalls: [(apps: [AppResult], query: String)] = []

    /// An array to store the queries passed to `fetchApps`.
    var fetchAppsCalls: [String] = []

    /// An array to store the 'days' values passed to `deleteOldApps`.
    var deleteOldAppsCalls: [Int] = []

    // MARK: - Stored results for predefined responses

    /// A dictionary to store predefined successful results for `fetchApps`.
    /// Key: query string, Value: Array of `AppResult`.
    var predefinedFetchedApps: [String: [AppResult]] = [:]

    /// A dictionary to store predefined errors for specific methods or queries.
    /// The key is a string representing the method or a combination of method and query.
    var predefinedErrors: [String: Error] = [:]

    /// A default error to throw if no specific error is set.
    var defaultError: Error?

    // MARK: - CoreDataManagerProtocol Conformance

    func saveApps(_ apps: [AppResult], for query: String) throws {
        // Record the call
        saveAppsCalls.append((apps: apps, query: query))

        // Check for specific error for this save operation
        if let error = predefinedErrors["saveApps_query_\(query)"] {
            throw error
        } else if let error = predefinedErrors["saveApps"] { // General save error
            throw error
        } else if let error = defaultError {
            throw error
        }
        // If no error is thrown, the operation is considered successful
    }

    func fetchApps(for query: String) throws -> [AppResult] {
        // Record the call
        fetchAppsCalls.append(query)

        // Check for specific error for this fetch operation
        if let error = predefinedErrors["fetchApps_query_\(query)"] {
            throw error
        } else if let error = predefinedErrors["fetchApps"] { // General fetch error
            throw error
        } else if let error = defaultError {
            throw error
        }

        // Return predefined results if available
        if let results = predefinedFetchedApps[query] {
            return results
        } else {
            // Default empty array if no specific results are set
            return []
        }
    }

    func deleteOldApps(olderThan days: Int) throws {
        // Record the call
        deleteOldAppsCalls.append(days)

        // Check for specific error for this delete operation
        if let error = predefinedErrors["deleteOldApps_days_\(days)"] {
            throw error
        } else if let error = predefinedErrors["deleteOldApps"] { // General delete error
            throw error
        } else if let error = defaultError {
            throw error
        }
        // If no error is thrown, the operation is considered successful
    }

    // MARK: - Helper Methods for Mock Configuration

    /// Sets a predefined successful array of `AppResult` for `fetchApps` for a given query.
    /// - Parameters:
    ///   - apps: The array of `AppResult` to return on success.
    ///   - query: The specific query for which these results should be provided.
    func setFetchSuccess(apps: [AppResult], forQuery query: String) {
        predefinedFetchedApps[query] = apps
    }

    /// Sets an error to be thrown by a specific method or for a specific query.
    /// - Parameters:
    ///   - error: The `Error` to throw.
    ///   - methodName: The name of the method (e.g., "saveApps", "fetchApps", "deleteOldApps").
    ///   - query: (Optional) The specific query for which the error should be thrown.
    ///   - days: (Optional) The specific 'days' value for which the error should be thrown (for deleteOldApps).
    func setError(_ error: Error, forMethod methodName: String, query: String? = nil, days: Int? = nil) {
        var key = methodName
        if let q = query {
            key += "_query_\(q)"
        } else if let d = days {
            key += "_days_\(d)"
        }
        predefinedErrors[key] = error
    }

    /// Sets a default error to be thrown by any method if no specific error is defined.
    func setDefaultError(_ error: Error) {
        self.defaultError = error
    }

    /// Resets all recorded calls and predefined results/errors.
    func reset() {
        saveAppsCalls = []
        fetchAppsCalls = []
        deleteOldAppsCalls = []
        predefinedFetchedApps = [:]
        predefinedErrors = [:]
        defaultError = nil
    }
}
