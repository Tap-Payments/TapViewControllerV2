//
//  AlertViewController.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2
import TapFontsKitV2

/// Alert View Controller
open class AlertViewController: PopupViewController, ViewControllerPopup {

    // MARK: - Open -
    // MARK: Properties

    /// Delegate.
    open weak var delegate: AlertViewControllerDelegate?

    /// Title text.
    open var titleText: String? {

        didSet {

            self.updateTitle()
        }
    }

    /// Attributed title text.
    open weak var attributedTitleText: NSAttributedString? {

        didSet {

            self.updateTitle()
        }
    }

    /// Description text.
    open var descriptionText: String? {

        didSet {

            self.updateDescription()
        }
    }

    /// Attributed description text.
    open weak var attributedDescriptionText: NSAttributedString? {

        didSet {

            self.updateDescription()
        }
    }

    /// Image.
    open weak var iconImage: UIImage? {

        didSet {

            self.updateImage()
        }
    }

    /// Image URL.
    open var imageURL: URL? {

        didSet {

            self.updateImage()
        }
    }

    ///Flag Image
    open var flagImage: UIImage? {

        didSet {

            self.updateImage()
        }
    }

    /// Button title.
    open var buttonTitle: String? {

        didSet {

            self.updateButton()
        }
    }

    // MARK: Methods

    open override class func instantiate() -> Self {

        guard let alertController = UIStoryboard.viewController.instantiateViewController(withIdentifier: self.tap_className) as? AlertViewController else {

            fatalError("Failed to instantiate \(self.tap_className) from storyboard.")
        }

        alertController.statusBarStyle = .default
        alertController.view.frame = UIScreen.main.bounds

        alertController.dismissCompletionClosure = { [weak alertController] in

            alertController?.delegate?.alertViewControllerDidDismiss?(alertController!)
        }

        return alertController.tap_asSelf()
    }

    open override func viewDidLoad() {

        super.viewDidLoad()
        self.updateButton()
    }

    open override func viewWillLayoutSubviews() {

        if let windowHeight = self.view.window?.bounds.height {

            self.viewHeightConstraint?.constant = windowHeight
        }

        if let nonnullDescriptionLabel = self.descriptionLabel {

            nonnullDescriptionLabel.preferredMaxLayoutWidth = nonnullDescriptionLabel.bounds.width
        }

        super.viewWillLayoutSubviews()
    }

    open override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        self.updateViewHeight()
    }

    open override func updateLocalization() {

        super.updateLocalization()

        self.button?.titleLabel?.font = TapFont.helveticaNeueRegular.localizedWithSize(15.0, languageIdentifier: Locale.current.identifier)
        self.titleLabel?.font = TapFont.helveticaNeueRegular.localizedWithSize(18.0,languageIdentifier: Locale.current.identifier)
        self.descriptionLabel?.font = TapFont.helveticaNeueLight.localizedWithSize(15.0,languageIdentifier: Locale.current.identifier)

        self.updateTitleLabelTopOffsetConstraint()
        self.updateTitleLabelHeightConstraint()

        self.updateDescriptionLabelTopOffsetConstraint()
        self.updateDescriptionLabelHeightConstraint()

        self.alertContentView?.tap_layout()
    }

    deinit {

        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let alertViewControllerContentOffsetWithoutButton: CGFloat = 0.0
        fileprivate static let alertViewControllerContentOffsetWithButton: CGFloat = 30.0

        fileprivate static let alertViewControllerMaximalTopOffset: CGFloat = 90.0

        fileprivate static let alertViewControllerTitleLabelDefaultTopOffset: CGFloat = 25.0
        fileprivate static let alertViewControllerTitleLabelArabicTopOffset: CGFloat = 0.0

        fileprivate static let alertViewControllerDescriptionLabelDefaultTopOffset: CGFloat = 10.0
        fileprivate static let alertViewControllerDescriptionLabelArabicTopOffset: CGFloat = 0.0

        fileprivate static let closeButtonImage: UIImage = {

            guard let result = UIImage(named: "btn_close_popup", in: .viewControllerResourcesBundle, compatibleWith: nil) else {

                fatalError("Failed to load image named btn_close_popup from view controller resources bundle.")
            }

            return result
        }()

        @available(*, unavailable) private init() {}
    }

    // MARK: IBOutlets

    @IBOutlet private weak var darkBackgroundView: UIView?
    @IBOutlet private weak var alertContentView: UIView?

    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var imageActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var button: UIButton?

    @IBOutlet private weak var closeButton: UIButton? {

        didSet {

            self.closeButton?.setImage(Constants.closeButtonImage, for: .normal)
        }
    }

    @IBOutlet private weak var titleLabelHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var descriptionLabelHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var titleLabelTopOffsetConstraint: NSLayoutConstraint?
    @IBOutlet private weak var descriptionLabelTopOffsetConstraint: NSLayoutConstraint?
    @IBOutlet private weak var verticalContentAlignmentConstraint: NSLayoutConstraint?
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint?

    @IBOutlet private weak var viewHeightConstraint: NSLayoutConstraint?

    // MARK: IBActions

    @IBAction private func closeButtonTouchUpInside(_ sender: UIButton) {

        self.hide(animated: true)
    }

    @IBAction private func buttonTouchUpInside(_ sender: UIButton) {

        delegate?.alertViewControllerButtonClicked?(self)
    }

    // MARK: Methods

    private func updateTitle() {

        self.tap_loadViewIfNotLoaded()

        if self.attributedTitleText == nil {

            self.titleLabel?.text = self.titleText
        } else {

            self.titleLabel?.attributedText = self.attributedTitleText
        }

        self.updateTitleLabelHeightConstraint()
        self.titleLabel?.tap_layout()
    }

    private func updateTitleLabelHeightConstraint() {

        guard let nonnullTitleLabel = self.titleLabel else { return }

        let titleSize = nonnullTitleLabel.sizeThatFits(CGSize(width: nonnullTitleLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        self.titleLabelHeightConstraint?.constant = titleSize.height
    }

    private func updateTitleLabelTopOffsetConstraint() {

        if TapViewControllerConnector.applicationInterface?.layoutDirection == .rightToLeft {

            self.titleLabelTopOffsetConstraint?.constant = Constants.alertViewControllerTitleLabelArabicTopOffset
        } else {

            self.titleLabelTopOffsetConstraint?.constant = Constants.alertViewControllerTitleLabelDefaultTopOffset
        }
    }

    private func updateDescription() {

        self.tap_loadViewIfNotLoaded()

        if self.attributedDescriptionText == nil {

            self.descriptionLabel?.text = self.descriptionText
        } else {

            self.descriptionLabel?.attributedText = self.attributedDescriptionText
        }

        self.updateDescriptionLabelHeightConstraint()
        self.descriptionLabel?.tap_layout()
    }

    private func updateDescriptionLabelHeightConstraint() {

        guard let nonnullDescriptionLabel = self.descriptionLabel else { return }

        let descriptionSize = nonnullDescriptionLabel.sizeThatFits(CGSize(width: nonnullDescriptionLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        self.descriptionLabelHeightConstraint?.constant = descriptionSize.height
    }

    private func updateDescriptionLabelTopOffsetConstraint() {

        if TapViewControllerConnector.applicationInterface?.layoutDirection == .rightToLeft {

            self.descriptionLabelTopOffsetConstraint?.constant = Constants.alertViewControllerDescriptionLabelArabicTopOffset
        } else {

            self.descriptionLabelTopOffsetConstraint?.constant = Constants.alertViewControllerDescriptionLabelDefaultTopOffset
        }
    }

    private func updateImage() {

        self.tap_loadViewIfNotLoaded()

        if let flag = self.flagImage {

            self.imageView?.image = flag
        } else if self.imageURL == nil {

            self.imageView?.image = self.iconImage ?? TapViewControllerConnector.fallbackAlertControllerImage
        } else {

            guard let nonnullDownloader = TapViewControllerConnector.imageDownloader, let url = self.imageURL else {

                self.imageView?.image = TapViewControllerConnector.fallbackAlertControllerImage
                return
            }

            let completion: TypeAlias.OptionalImageClosure = { [weak self] image in

                self?.imageActivityIndicatorView?.stopAnimating()
                self?.imageView?.image = image ?? TapViewControllerConnector.fallbackAlertControllerImage
            }

            self.imageActivityIndicatorView?.startAnimating()

            nonnullDownloader.downloadImage(from: url, completion: completion)
        }
    }

    private func updateButton() {

        self.tap_loadViewIfNotLoaded()

        let btnTitle = self.buttonTitle ?? String.tap_empty

        self.button?.tap_title = btnTitle

        if btnTitle.tap_length > 0 {

            self.button?.isHidden = false
            self.verticalContentAlignmentConstraint?.constant = Constants.alertViewControllerContentOffsetWithButton
        } else {

            self.button?.isHidden = true
            self.verticalContentAlignmentConstraint?.constant = Constants.alertViewControllerContentOffsetWithoutButton
        }

        self.alertContentView?.tap_layout()
    }

    private func updateViewHeight() {

        guard let nonnullHeightConstraint = self.heightConstraint else { return }

        let viewHeight = view.bounds.height
        if nonnullHeightConstraint.constant + 2.0 * Constants.alertViewControllerMaximalTopOffset < viewHeight {

            nonnullHeightConstraint.constant = viewHeight - 2.0 * Constants.alertViewControllerMaximalTopOffset
            self.alertContentView?.tap_layout()
        }
    }

    public weak var backgroundView: UIView? {

        self.tap_loadViewIfNotLoaded()

        return self.darkBackgroundView
    }

    public weak var popupView: UIView? {

        self.tap_loadViewIfNotLoaded()

        return self.alertContentView
    }
}
