import UIKit

class AppTableViewCell: UITableViewCell {
    
    private let appIconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let developerLabel = UILabel()
    private let categoryLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let ratingLabel = UILabel()
    private let priceLabel = UILabel()
    
    private var viewModel: AppCellViewModelProtocol?
    private var imageLoadTask: Task<Void, Never>?
    private let imageLoader = ImageLoader()
    private let style: Style = Style()
    private let layout: Layout = Layout()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        appIconImageView.image = nil
        viewModel = nil
    }
    
    private func setupUI() {
        // App Icon
        appIconImageView.layer.cornerRadius = self.layout.appIconCornerRadius
        appIconImageView.clipsToBounds = true
        appIconImageView.contentMode = self.style.appIconContentMode
        appIconImageView.backgroundColor = self.style.appIconBackgroundColor
        
        // App Name
        appNameLabel.font = self.style.appNameFont
        appNameLabel.numberOfLines = 1
        
        // Developer
        developerLabel.font = self.style.developerFont
        developerLabel.textColor = self.style.developerTextColor
        developerLabel.numberOfLines = 1
        
        // Category
        categoryLabel.font = self.style.categoryFont
        categoryLabel.textColor = self.style.categoryTextColor
        categoryLabel.numberOfLines = 1
        
        // Rating Stack View
        ratingStackView.axis = .horizontal
        ratingStackView.alignment = .center
        ratingStackView.spacing = self.layout.ratingStackSpacing
        ratingStackView.distribution = self.style.ratingStackDistribution
        
        // Rating Label
        ratingLabel.font = self.style.ratingFont
        ratingLabel.textColor = self.style.ratingTextColor
        ratingLabel.numberOfLines = 1
                
        // Price
        priceLabel.font = self.style.priceFont
        priceLabel.textColor = self.style.priceTextColor
        priceLabel.numberOfLines = 1
        priceLabel.textAlignment = self.style.priceTextAlignment
        
        // Add to content view
        [appIconImageView, appNameLabel, developerLabel, categoryLabel,
         ratingStackView, ratingLabel, priceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // App Icon
            appIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.appIconLeadingSpacing),
            appIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: self.layout.appIcon.width),
            appIconImageView.heightAnchor.constraint(equalToConstant: self.layout.appIcon.height),
            
            // App Name
            appNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: self.layout.appNameTopSpacing),
            appNameLabel.leadingAnchor.constraint(equalTo: appIconImageView.trailingAnchor, constant: self.layout.appNameLeadingSpacing),
            appNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: self.layout.appNameTrailingSpacing),
            
            // Developer
            developerLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: self.layout.developerTopSpacing),
            developerLabel.leadingAnchor.constraint(equalTo: appNameLabel.leadingAnchor),
            developerLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: self.layout.developerTrailingSpacing),
            
            // Category
            categoryLabel.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: self.layout.categoryTopSpacing),
            categoryLabel.leadingAnchor.constraint(equalTo: appNameLabel.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: self.layout.categoryTrailingSpacing),
            
            // Rating Stack View
            ratingStackView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: self.layout.ratingStackTopSpacing),
            ratingStackView.leadingAnchor.constraint(equalTo: appNameLabel.leadingAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: self.layout.ratingStackHeight),
            
            // Rating Label
            ratingLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: self.layout.ratingLeadingSpacing),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: self.layout.ratingBottomSpacing),
            
            // Price
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: self.layout.priceTrailingSpacing),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: self.layout.priceMinimumWidth)
        ])
    }
    
    func configure(with viewModel: AppCellViewModelProtocol, accessibilityIdentifier: String) {
        self.viewModel = viewModel
        
        appNameLabel.text = viewModel.appName
        developerLabel.text = viewModel.developerName
        categoryLabel.text = viewModel.category
        priceLabel.text = viewModel.price
        ratingLabel.text = viewModel.ratingText
        setupStarRating(rating: viewModel.rating)
        loadImageAsync(from: viewModel.iconURL)
        
        appNameLabel.accessibilityIdentifier = accessibilityIdentifier + ".appName"
    }
    
    private func setupStarRating(rating: Double) {
        // Clear existing star views
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: self.layout.rating.width).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: self.layout.rating.height).isActive = true
            
            if rating >= Double(i) {
                starImageView.image = self.style.rating.full
                starImageView.tintColor = self.style.rating.fillColor
            } else if rating > Double(i - 1) {
                starImageView.image = self.style.rating.halfFull
                starImageView.tintColor = self.style.rating.fillColor
            } else {
                starImageView.image = self.style.rating.star
                starImageView.tintColor = self.style.rating.emptyColor
            }
            
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
    
    private func loadImageAsync(from urlString: String) {
        imageLoadTask?.cancel()
        
        imageLoadTask = Task {
            
            do {
                guard let image = try await self.imageLoader.loadImage(urlString: urlString),
                      !Task.isCancelled else { return }
                
                await MainActor.run {
                    // Ensure the cell hasn't been reused
                    if self.viewModel?.iconURL == urlString {
                        self.appIconImageView.image = image
                    }
                }
            } catch {
                // Handle image loading error silently
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        imageLoadTask?.cancel()
    }
    
    struct Style {
        struct Rating {
            let full = UIImage(systemName: "star.fill")
            let halfFull = UIImage(systemName: "star.leadinghalf.filled")
            let star = UIImage(systemName: "star")
            let fillColor = UIColor.systemYellow
            let emptyColor = UIColor.systemGray3
        }
        let rating = Rating()
        let appIconBackgroundColor = UIColor.systemGray6
        let appIconContentMode = UIView.ContentMode.scaleAspectFill
        let appNameFont = UIFont.boldSystemFont(ofSize: 16)
        let developerFont = UIFont.systemFont(ofSize: 13)
        let developerTextColor = UIColor.systemGray
        let categoryFont = UIFont.systemFont(ofSize: 12)
        let categoryTextColor = UIColor.systemBlue
        let ratingStackDistribution = UIStackView.Distribution.fillProportionally
        let ratingFont = UIFont.systemFont(ofSize: 12)
        let ratingTextColor = UIColor.systemGray
        let priceFont = UIFont.boldSystemFont(ofSize: 14)
        let priceTextColor = UIColor.systemBlue
        let priceTextAlignment = NSTextAlignment.right
    }
    struct Layout {
        let rating = CGSize(width: 12, height: 12)
        let appIcon = CGSize(width: 60, height: 60)
        let appIconLeadingSpacing = 16.0
        let appIconCornerRadius = 12.0
        let appNameTopSpacing = 12.0
        let appNameLeadingSpacing = 12.0
        let appNameTrailingSpacing = -8.0
        let developerTopSpacing = 4.0
        let developerTrailingSpacing = -8.0
        let categoryTopSpacing = 2.0
        let categoryTrailingSpacing = -8.0
        let ratingStackTopSpacing = 6.0
        let ratingStackHeight = 12.0
        let ratingStackSpacing = 2.0
        let ratingLeadingSpacing = 4.0
        let ratingBottomSpacing = -12.0
        let priceTrailingSpacing = -16.0
        let priceMinimumWidth = 50.0
    }
}
