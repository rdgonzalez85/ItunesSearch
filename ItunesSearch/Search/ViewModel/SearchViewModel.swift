import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var apps: [AppCellViewModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let numberOfCacheDays = 7
    private let iTunesService: iTunesServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private let networkReachability: NetworkReachabilityProtocol
    
    var numberOfApps: Int {
        return apps.count
    }
    
    init(iTunesService: iTunesServiceProtocol,
         coreDataManager: CoreDataManagerProtocol,
         networkReachability: NetworkReachabilityProtocol) {
        self.iTunesService = iTunesService
        self.coreDataManager = coreDataManager
        self.networkReachability = networkReachability
        
        self.networkReachability.startMonitoring()
        // Clean up old cached data on initialization
        Task {
            await cleanUpOldData()
        }
    }
    
    @MainActor
    func searchApps(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Online: Search from API and save to Core Data
        // Offline: Load from Core Data
        if networkReachability.isConnected {
            await searchFromAPI(query: query)
        } else {
            await loadFromCache(query: query)
        }
        
        isLoading = false
    }
    
    private func searchFromAPI(query: String) async {
        do {
            let appResults = try await iTunesService.searchApps(query: query)

            guard !Task.isCancelled else { return }

            await saveToCache(appResults, query: query)

            self.apps = appResults.map { AppCellViewModel(app: $0) }
        } catch {
            guard !Task.isCancelled else { return }

            await loadFromCache(query: query)

            if apps.isEmpty {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadFromCache(query: String) async {
        do {
            let cachedResults = try coreDataManager.fetchApps(for: query)
            
            if cachedResults.isEmpty {
                self.errorMessage = "No cached results found. Please check your internet connection."
                self.apps = []
            } else {
                self.apps = cachedResults.map { AppCellViewModel(app: $0) }
            }
            
        } catch {
            self.errorMessage = "Failed to load cached results: \(error.localizedDescription)"
            self.apps = []
        }
    }
    
    private func saveToCache(_ appResults: [AppResult], query: String) async {
        do {
            try coreDataManager.saveApps(appResults, for: query)
        } catch {
            print("Failed to save apps to cache: \(error.localizedDescription)")
        }
    }
    
    private func cleanUpOldData() async {
        do {
            // Only keep results for the last $numberOfCacheDays days
            try coreDataManager.deleteOldApps(olderThan: self.numberOfCacheDays)
        } catch {
            print("Failed to clean up old data: \(error.localizedDescription)")
        }
    }
    
    func appViewModel(at index: Int) -> AppCellViewModel {
        return apps[index]
    }
    
    func clearResults() {
        apps = []
        errorMessage = nil
    }
    
    func retrySearch(query: String) async {
        await searchApps(query: query)
    }
}
