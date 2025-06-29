import UIKit

protocol NavigationCoordinatorProtocol {
    func showAppDetails(for app: AppResult, from viewController: UIViewController)
}

class NavigationCoordinator: NavigationCoordinatorProtocol {
    init() {}
    
    func showAppDetails(for app: AppResult, from viewController: UIViewController) {
        let viewModel = AppDetailsViewModel(app: app)
        let imageLoader = ImageLoader()
        let detailsViewController = AppDetailsViewController(viewModel: viewModel, imageLoader: imageLoader)
        
        viewController.navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
