import UIKit

class AppDetailsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerContentStackView: UIStackView = UIStackView()
    private let appIconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let developerLabel = UILabel()
    private let categoryLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let ratingLabel = UILabel()
    private let priceButton = UIButton(type: .system)

    private let screenshotsLabel = UILabel()
    private let screenshotsCollectionView: UICollectionView

    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()

    private let informationLabel = UILabel()
    private let informationStackView = UIStackView()

    private var viewModel: AppDetailsViewModelProtocol
    private var imageLoadTask: Task<Void, Never>?
    private let imageLoader: ImageLoaderProtocol

    private let layout = Layout()
    private let style = Style()
    
    init(viewModel: AppDetailsViewModelProtocol, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.layout.screenshotItemWidth, height: self.layout.screenshotItemHeight)
        layout.minimumLineSpacing = self.layout.screenshotMinimumLineSpacing
        layout.sectionInset = self.layout.screenshotSectionInsets

        self.screenshotsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureView()
        setupAccessibility()
    }

    deinit {
        imageLoadTask?.cancel()
    }

    private func setupUI() {
        view.backgroundColor = self.style.systemBackgroundColor

        navigationItem.largeTitleDisplayMode = .never

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true

        contentView.translatesAutoresizingMaskIntoConstraints = false

        headerContentStackView.translatesAutoresizingMaskIntoConstraints = false
        headerContentStackView.axis = .horizontal
        headerContentStackView.alignment = .center
        headerContentStackView.spacing = self.layout.padding

        let appDetailsTextStack = UIStackView(arrangedSubviews: [appNameLabel, developerLabel, categoryLabel])
        appDetailsTextStack.axis = .vertical
        appDetailsTextStack.alignment = .leading
        appDetailsTextStack.spacing = self.layout.smallSpacing
        appDetailsTextStack.translatesAutoresizingMaskIntoConstraints = false


        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.layer.cornerRadius = self.layout.appIconCornerRadius
        appIconImageView.clipsToBounds = true
        appIconImageView.contentMode = .scaleAspectFit
        appIconImageView.backgroundColor = self.style.systemGray6Color

        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.font = self.style.appNameFont
        appNameLabel.numberOfLines = self.style.appNameNumberOfLines

        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        developerLabel.font = self.style.developerCategoryRatingFont
        developerLabel.textColor = self.style.systemBlueColor
        developerLabel.numberOfLines = self.style.singleLine

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = self.style.categoryRatingFont
        categoryLabel.textColor = self.style.systemGrayColor
        categoryLabel.numberOfLines = self.style.singleLine

        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.axis = .horizontal
        ratingStackView.alignment = .center
        ratingStackView.spacing = self.layout.smallSpacing

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = self.style.categoryRatingFont
        ratingLabel.textColor = self.style.systemGrayColor

        priceButton.translatesAutoresizingMaskIntoConstraints = false
        priceButton.backgroundColor = self.style.systemBlueColor
        priceButton.setTitleColor(self.style.whiteColor, for: .normal)
        priceButton.titleLabel?.font = self.style.priceButtonFont
        priceButton.layer.cornerRadius = self.layout.priceButtonCornerRadius
        priceButton.setContentHuggingPriority(.required, for: .horizontal)
        priceButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        headerContentStackView.addArrangedSubview(appIconImageView)
        headerContentStackView.addArrangedSubview(appDetailsTextStack)
        headerContentStackView.addArrangedSubview(priceButton)

        screenshotsLabel.translatesAutoresizingMaskIntoConstraints = false
        screenshotsLabel.text = self.style.screenshotsLabelText
        screenshotsLabel.font = self.style.sectionHeaderFont
        screenshotsLabel.numberOfLines = self.style.singleLine

        screenshotsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        screenshotsCollectionView.backgroundColor = .clear
        screenshotsCollectionView.showsHorizontalScrollIndicator = false
        screenshotsCollectionView.register(ScreenshotCollectionViewCell.self, forCellWithReuseIdentifier: "ScreenshotCell")
        screenshotsCollectionView.dataSource = self
        screenshotsCollectionView.delegate = self

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = self.style.descriptionLabelText
        descriptionLabel.font = self.style.sectionHeaderFont
        descriptionLabel.numberOfLines = self.style.singleLine

        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.font = self.style.descriptionFont
        descriptionTextView.textColor = self.style.labelColor
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0

        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.text = self.style.informationLabelText
        informationLabel.font = self.style.sectionHeaderFont
        informationLabel.numberOfLines = self.style.singleLine

        informationStackView.translatesAutoresizingMaskIntoConstraints = false
        informationStackView.axis = .vertical
        informationStackView.spacing = self.layout.informationStackViewSpacing
        informationStackView.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [headerContentStackView, ratingStackView, ratingLabel, screenshotsLabel,
         screenshotsCollectionView, descriptionLabel, descriptionTextView,
         informationLabel, informationStackView].forEach {
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerContentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: self.layout.headerTopPadding),
            headerContentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            headerContentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),

            appIconImageView.widthAnchor.constraint(equalToConstant: self.layout.appIconSize),
            appIconImageView.heightAnchor.constraint(equalToConstant: self.layout.appIconSize),

            priceButton.heightAnchor.constraint(equalToConstant: self.layout.priceButtonHeight),
            priceButton.widthAnchor.constraint(greaterThanOrEqualToConstant: self.layout.priceButtonMinimumWidth),

            ratingStackView.topAnchor.constraint(equalTo: headerContentStackView.bottomAnchor, constant: self.layout.mediumSpacing),
            ratingStackView.leadingAnchor.constraint(equalTo: appIconImageView.leadingAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: self.layout.ratingStackViewHeight),

            ratingLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: self.layout.ratingLabelLeadingSpacing),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor),

            screenshotsLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: self.layout.sectionSpacing),
            screenshotsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            screenshotsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),

            screenshotsCollectionView.topAnchor.constraint(equalTo: screenshotsLabel.bottomAnchor, constant: self.layout.largeSpacing),
            screenshotsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            screenshotsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            screenshotsCollectionView.heightAnchor.constraint(equalToConstant: self.layout.screenshotCollectionViewHeight),

            descriptionLabel.topAnchor.constraint(equalTo: screenshotsCollectionView.bottomAnchor, constant: self.layout.sectionSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: self.layout.largeSpacing),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),

            informationLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: self.layout.sectionSpacing),
            informationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            informationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),

            informationStackView.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: self.layout.largeSpacing),
            informationStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.layout.padding),
            informationStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -self.layout.padding),
            informationStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -self.layout.sectionSpacing)
        ])
    }

    private func configureView() {
        appNameLabel.text = viewModel.appName
        developerLabel.text = viewModel.developerName
        categoryLabel.text = viewModel.category
        priceButton.setTitle(viewModel.price, for: .normal)
        ratingLabel.text = viewModel.ratingText
        descriptionTextView.text = viewModel.description

        setupStarRating()
        setupInformationSection()
        loadAppIcon()
    }

    private func setupStarRating() {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rating = viewModel.rating
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: self.layout.starImageSize).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: self.layout.starImageSize).isActive = true

            if rating >= Double(i) {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = self.style.systemYellowColor
            } else if rating > Double(i - 1) {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = self.style.systemYellowColor
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = self.style.systemGray3Color
            }

            ratingStackView.addArrangedSubview(starImageView)
        }
    }

    private func setupInformationSection() {
        informationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let infoItems = viewModel.informationItems

        for item in infoItems {
            let containerView = UIView()

            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = self.style.informationTitleFont
            titleLabel.textColor = self.style.systemGrayColor
            titleLabel.numberOfLines = self.style.singleLine

            let valueLabel = UILabel()
            valueLabel.text = item.value
            valueLabel.font = self.style.informationValueFont
            valueLabel.textColor = self.style.labelColor
            valueLabel.numberOfLines = self.style.multiLine

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            containerView.addSubview(titleLabel)
            containerView.addSubview(valueLabel)

            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: self.layout.informationValueTopSpacing),
                valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])

            informationStackView.addArrangedSubview(containerView)
        }
    }

    private func loadAppIcon() {
        imageLoadTask?.cancel()

        imageLoadTask = Task {
            do {
                guard let image = try await self.imageLoader.loadImage(urlString: viewModel.iconURL),
                      !Task.isCancelled else { return }

                await MainActor.run {
                    self.appIconImageView.image = image
                }
            } catch {
                print("Failed to load app icon: \(error.localizedDescription)")
            }
        }
    }

    private func setupAccessibility() {
        headerContentStackView.isAccessibilityElement = true
        headerContentStackView.accessibilityLabel = "\(viewModel.appName) by \(viewModel.developerName). Category: \(viewModel.category). \(viewModel.price) to download."
        headerContentStackView.accessibilityTraits = .staticText
        
        appIconImageView.isAccessibilityElement = false
        appNameLabel.isAccessibilityElement = false
        developerLabel.isAccessibilityElement = false
        categoryLabel.isAccessibilityElement = false
        priceButton.isAccessibilityElement = true
        priceButton.accessibilityLabel = "\(viewModel.price) app. Tap to get."
        
        ratingStackView.isAccessibilityElement = true
        ratingStackView.accessibilityLabel = viewModel.ratingText
        ratingStackView.accessibilityTraits = .staticText
        ratingLabel.isAccessibilityElement = false
        ratingStackView.arrangedSubviews.forEach { $0.isAccessibilityElement = false }


        screenshotsLabel.isAccessibilityElement = true
        screenshotsLabel.accessibilityTraits = .header

        screenshotsCollectionView.isAccessibilityElement = true
        screenshotsCollectionView.accessibilityLabel = "App Screenshots"
        screenshotsCollectionView.accessibilityTraits = .adjustable

        descriptionLabel.isAccessibilityElement = true
        descriptionLabel.accessibilityTraits = .header

        descriptionTextView.isAccessibilityElement = true
        descriptionTextView.accessibilityLabel = viewModel.description
        descriptionTextView.accessibilityTraits = .staticText

        informationLabel.isAccessibilityElement = true
        informationLabel.accessibilityTraits = .header

        informationStackView.isAccessibilityElement = false
        for (index, subview) in informationStackView.arrangedSubviews.enumerated() {
            let container = subview
            if  index < viewModel.informationItems.count {
                let item = viewModel.informationItems[index]
                container.isAccessibilityElement = true
                container.accessibilityLabel = "\(item.title), \(item.value)"
                container.accessibilityTraits = .staticText
                container.subviews.forEach { $0.isAccessibilityElement = false }
            }
        }
        
        self.view.accessibilityElements = [
            headerContentStackView,
            priceButton,
            ratingStackView,
            screenshotsLabel,
            screenshotsCollectionView,
            descriptionLabel,
            descriptionTextView,
            informationLabel
        ]
    }
    
    struct Layout {
        let padding: CGFloat = 16.0
        let smallSpacing: CGFloat = 4.0
        let mediumSpacing: CGFloat = 8.0
        let largeSpacing: CGFloat = 12.0
        let headerTopPadding: CGFloat = 20.0
        let sectionSpacing: CGFloat = 32.0

        let appIconSize: CGFloat = 100.0
        let appIconCornerRadius: CGFloat = 20.0

        let ratingStackViewHeight: CGFloat = 20.0
        let starImageSize: CGFloat = 16.0
        let ratingLabelLeadingSpacing: CGFloat = 8.0

        let priceButtonHeight: CGFloat = 40.0
        let priceButtonMinimumWidth: CGFloat = 80.0
        let priceButtonCornerRadius: CGFloat = 20.0
        let priceButtonHorizontalSpacing: CGFloat = 16.0

        let screenshotItemWidth: CGFloat = 200.0
        let screenshotItemHeight: CGFloat = 350.0
        let screenshotMinimumLineSpacing: CGFloat = 12.0
        let screenshotSectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let screenshotCollectionViewHeight: CGFloat = 350.0
        let screenshotCornerRadius: CGFloat = 12.0

        let informationStackViewSpacing: CGFloat = 12.0
        let informationValueTopSpacing: CGFloat = 4.0
    }

    struct Style {
        let systemBackgroundColor: UIColor = .systemBackground
        let labelColor: UIColor = .label
        let systemBlueColor: UIColor = .systemBlue
        let systemGrayColor: UIColor = .systemGray
        let systemGray3Color: UIColor = .systemGray3
        let systemGray6Color: UIColor = .systemGray6
        let systemYellowColor: UIColor = .systemYellow
        let whiteColor: UIColor = .white

        let appNameFont: UIFont = .boldSystemFont(ofSize: 22)
        let developerCategoryRatingFont: UIFont = .systemFont(ofSize: 16)
        let categoryRatingFont: UIFont = .systemFont(ofSize: 14)
        let priceButtonFont: UIFont = .boldSystemFont(ofSize: 16)
        let sectionHeaderFont: UIFont = .boldSystemFont(ofSize: 18)
        let descriptionFont: UIFont = .systemFont(ofSize: 16)
        let informationTitleFont: UIFont = .systemFont(ofSize: 14, weight: .medium)
        let informationValueFont: UIFont = .systemFont(ofSize: 16)

        let screenshotsLabelText: String = "Screenshots"
        let descriptionLabelText: String = "Description"
        let informationLabelText: String = "Information"

        let appNameNumberOfLines: Int = 2
        let singleLine: Int = 1
        let multiLine: Int = 0
    }
    
    // set some empty images in case there are none
    private let defaultNumberOfScreenshots = 4
}

extension AppDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.screenshotURLs.count > 0 ? viewModel.screenshotURLs.count : self.defaultNumberOfScreenshots
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCell", for: indexPath) as? ScreenshotCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.item < viewModel.screenshotURLs.count {
            let screenshotURL = viewModel.screenshotURLs[indexPath.item]
            cell.configure(with: screenshotURL)
        }
        return cell
    }
}

class ScreenshotCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private var imageLoadTask: Task<Void, Never>?
    private let imageLoader: ImageLoaderProtocol = ImageLoader()
    
    private let style = Style()
    private let layout = Layout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageView.image = nil
    }

    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = self.style.systemGray6Color
        imageView.layer.cornerRadius = self.layout.screenshotCornerRadius
        imageView.clipsToBounds = true

        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with urlString: String) {
        imageLoadTask?.cancel()

        imageLoadTask = Task {
            do {
                guard let image = try await self.imageLoader.loadImage(urlString: urlString),
                      !Task.isCancelled else { return }

                await MainActor.run {
                    self.imageView.image = image
                }
            } catch {
                print("Failed to load screenshot: \(error.localizedDescription)")
            }
        }
    }

    deinit {
        imageLoadTask?.cancel()
    }

    private func setupAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = "App Screenshot"
        self.accessibilityTraits = .image
        imageView.isAccessibilityElement = false
    }
    
    struct Layout {
        let screenshotCornerRadius: CGFloat = 12.0
    }
    
    struct Style {
        let systemGray6Color = UIColor.systemGray6
    }
}
