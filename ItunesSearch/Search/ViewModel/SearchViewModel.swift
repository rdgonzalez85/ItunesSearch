import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var apps: [AppCellViewModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let iTunesService: iTunesServiceProtocol
    
    var numberOfApps: Int {
        return apps.count
    }
    
    init(iTunesService: iTunesServiceProtocol) {
        self.iTunesService = iTunesService
    }
    
    func searchApps(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let appResults = try await iTunesService.searchApps(query: query)
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            self.apps = appResults.map { AppCellViewModel(app: $0) }
        } catch {
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            self.errorMessage = error.localizedDescription
        }
            
        isLoading = false
    }
    
    func appViewModel(at index: Int) -> AppCellViewModel {
        return apps[index]
    }
    
    func clearResults() {
        apps = []
        errorMessage = nil
    }
}
