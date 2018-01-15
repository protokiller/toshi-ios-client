// Copyright (c) 2017 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SweetUIKit
import UIKit

protocol PersonalProfileViewDelegate: class {
    func didTapEditProfile(in profileView: ProfileView)
}

protocol ProfileViewDelegate: class {
    func didTapMessage(in profileView: ProfileView)
    func didTapPay(in profileView: ProfileView)
    func didTapRateUser(in profileView: ProfileView)
}

class ProfileView: UIView {

    // MARK: - ViewType
    
    enum ViewType {
        case profile
        case personalProfile
        case personalProfileReadOnly
        
        private var isSomeoneElsesProfile: Bool {
            switch self {
            case .profile:
                return true
            default:
                return false
            }
        }
        
        var shouldShowEditProfileButton: Bool {
            switch self {
            case .personalProfile:
                return true
            default:
                return false
            }
        }
        
        var shouldShowMoreButton: Bool {
            return isSomeoneElsesProfile
        }
        
        var shouldShowRateUserButton: Bool {
            return isSomeoneElsesProfile
        }
        
        var shouldShowPayButton: Bool {
            return isSomeoneElsesProfile
        }
    }
    
    // MARK: - Properties

    weak var personalProfileDelegate: PersonalProfileViewDelegate?
    weak var profileDelegate: ProfileViewDelegate?
    weak var navBarDelegate: DisappearingBackgroundNavBarDelegate?
    
    private let margin: CGFloat = 15
    
    private let tinyInterItemSpacing: CGFloat = 5
    private let mediumInterItemSpacing: CGFloat = 10
    private let largeInterItemSpacing: CGFloat = 20
    private let giantInterItemSpacing: CGFloat = 40
    private let belowTableViewStyleLabelSpacing: CGFloat = 8
    
    private let avatarSide: CGFloat = 60
    private let buttonHeight: CGFloat = 44
    
    lazy var disappearingNavBar: DisappearingBackgroundNavBar = {
        let navBar = DisappearingBackgroundNavBar(delegate: navBarDelegate)
        navBar.setupLeftAsBackButton()

        return navBar
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = true
        view.delaysContentTouches = false
        if #available(iOS 11, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        
        return view
    }()
    
    /// The view containing all content within the scroll view.
    private lazy var containerView = UIView()
    
    private lazy var topSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.viewBackgroundColor
    
        return view
    }()
    
    lazy var profileDetailsStackView: UIStackView = {
        let view = UIStackView()
        view.addBackground(with: Theme.viewBackgroundColor)
        view.axis = .vertical
        view.alignment = .center
        
        return view
    }()

    private lazy var avatarImageView = AvatarImageView()

    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Theme.preferredTitle2()
        view.textAlignment = .center
        view.adjustsFontForContentSizeCategory = true

        return view
    }()

    lazy var usernameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        view.font = Theme.preferredRegularMedium()
        view.adjustsFontForContentSizeCategory = true
        view.textColor = Theme.greyTextColor

        return view
    }()
    
    lazy var messageUserButton: ActionButton = {
        let button = ActionButton(margin: margin)
        button.setButtonStyle(.primary)
        button.title = Localized("profile_message_button_title")
        button.addTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var payButton: ActionButton = {
        let button = ActionButton(margin: margin)
        button.setButtonStyle(.secondary)
        button.title = Localized("profile_pay_button_title")
        button.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var editProfileButton: ActionButton = {
        let view = ActionButton(margin: margin)
        view.setButtonStyle(.secondary)
        view.title = Localized("profile_edit_button_title")
        view.addTarget(self, action: #selector(didTapEditProfileButton), for: .touchUpInside)
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var aboutTopSeparatorView = BorderView()

    lazy var aboutContentLabel: UILabel = {
        let view = UILabel()
        view.font = Theme.preferredRegular()
        view.adjustsFontForContentSizeCategory = true
        view.numberOfLines = 0

        return view
    }()

    lazy var locationContentLabel: UILabel = {
        let view = UILabel()
        view.font = Theme.preferredRegularMedium()
        view.adjustsFontForContentSizeCategory = true
        view.textColor = Theme.lightGreyTextColor
        view.numberOfLines = 0

        return view
    }()
    
    private lazy var aboutBottomSeparatorView = BorderView()

    lazy var reputationTitle: UILabel = {
        let view = UILabel()
        view.font = Theme.preferredFootnote()
        view.textColor = Theme.sectionTitleColor
        view.text = Localized("profile_reputation_section_header")
        view.adjustsFontForContentSizeCategory = true
        
        return view
    }()

    lazy var reputationStackView: UIStackView = {
        let view = UIStackView()
        view.addBackground(with: Theme.viewBackgroundColor)
        view.axis = .vertical
        view.alignment = .center
        
        return view
    }()
    
    private lazy var reputationTopSeparatorView = BorderView()
    
    private(set) lazy var reputationView = ReputationView()

    lazy var rateThisUserButton: UIButton = {
        let view = UIButton()
        view.setTitle(Localized("profile_rate_user"), for: .normal)
        view.setTitleColor(Theme.tintColor, for: .normal)
        view.setTitleColor(Theme.greyTextColor, for: .highlighted)
        view.titleLabel?.font = Theme.preferredRegular()
        view.titleLabel?.adjustsFontForContentSizeCategory = true
        view.clipsToBounds = true

        view.addTarget(self, action: #selector(didTapRateUserButton), for: .touchUpInside)
        
        return view
    }()

    private lazy var reputationBottomSeparatorView = BorderView()
        
    // MARK: - Setter
    
    func setProfile(_ user: TokenUser) {
        if !user.name.isEmpty {
            nameLabel.text = user.name
        } else {
            nameLabel.text = nil
        }
        
        usernameLabel.text = user.displayUsername

        if user.isApp {
            if payButton.superview != nil {
                profileDetailsStackView.removeArrangedSubviewAndSpacingAfter(arrangedSubview: payButton)
            }
            
            rateThisUserButton.setTitle(Localized("profile_rate_bot"), for: .normal)
        }
        
        aboutContentLabel.text = user.about
        locationContentLabel.text = user.location
        
        if !aboutContentLabel.hasContent && !locationContentLabel.hasContent {
            profileDetailsStackView.removeArrangedSubviewAndSpacingAfter(arrangedSubview: aboutContentLabel)
            profileDetailsStackView.removeArrangedSubviewAndSpacingAfter(arrangedSubview: locationContentLabel)
            profileDetailsStackView.removeArrangedSubviewAndSpacingAfter(arrangedSubview: aboutTopSeparatorView)
        }
        
        AvatarManager.shared.avatar(for: user.avatarPath) { [weak self] image, _ in
            if image != nil {
                self?.avatarImageView.image = image
            }
        }
    }

    // MARK: - Initialization & Setup

    init(viewType: ViewType, navBarDelegate: DisappearingBackgroundNavBarDelegate) {
        super.init(frame: CGRect.zero)
        
        self.navBarDelegate = navBarDelegate
        
        addSubviewsAndConstraints(for: viewType)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviewsAndConstraints(for viewType: ViewType) {
        let navBarHeight = DisappearingBackgroundNavBar.defaultHeight
        setupScrollView(navBarHeight: navBarHeight)
        setupDisappearingNavBar(height: navBarHeight, for: viewType)
        setupContainerView(in: scrollView, for: viewType)
    }

    // MARK: Outer layout
    
    private func setupScrollView(navBarHeight: CGFloat) {
        addSubview(scrollView)
        scrollView.edgesToSuperview(excluding: .bottom)
        if #available(iOS 11, *) {
            scrollView.bottom(to: self.safeAreaLayoutGuide)
        } else {
            scrollView.bottom(to: self)
        }
    }
    
    private func setupDisappearingNavBar(height: CGFloat, for viewType: ViewType) {
        addSubview(disappearingNavBar)
        
        disappearingNavBar.edgesToSuperview(excluding: .bottom)
        disappearingNavBar.height(height)
    
        if viewType.shouldShowMoreButton {
            disappearingNavBar.setRightButtonImage(#imageLiteral(resourceName: "more_centered"), accessibilityLabel: Localized("accessibility_more"))
        }
    }
    
    private func setupContainerView(in scrollView: UIScrollView, for viewType: ViewType) {
        assert(scrollView.superview != nil)
        scrollView.addSubview(containerView)
        
        containerView.edgesToSuperview()
        containerView.width(to: scrollView)
        
        addTopSpacer(to: containerView)
        addProfileDetailsStackView(to: containerView, below: topSpacer, for: viewType)
        addReputationTitle(to: containerView, below: profileDetailsStackView)
        addReputationStackView(to: containerView, below: reputationTitle, for: viewType)
    }
    
    private func addTopSpacer(to container: UIView) {
        assert(container.superview != nil)
        container.addSubview(topSpacer)
        
        topSpacer.edgesToSuperview(excluding: .bottom)
        topSpacer.height(DisappearingBackgroundNavBar.defaultHeight)
    }
    
    private func addProfileDetailsStackView(to container: UIView, below viewToPinToBottomOf: UIView, for viewType: ViewType) {
        container.addSubview(profileDetailsStackView)
        profileDetailsStackView.leftToSuperview()
        profileDetailsStackView.rightToSuperview()
        profileDetailsStackView.topToBottom(of: viewToPinToBottomOf)
        
        profileDetailsStackView.addAndCenterPin(view: avatarImageView)
        avatarImageView.height(avatarSide)
        avatarImageView.width(avatarSide)
        profileDetailsStackView.addSpacing(margin, after: avatarImageView)
        
        profileDetailsStackView.addAndStandardPin(view: nameLabel)
        profileDetailsStackView.addSpacing(tinyInterItemSpacing, after: nameLabel)

        profileDetailsStackView.addAndStandardPin(view: usernameLabel)
        
        addButtonsAndSpacing(for: viewType, to: profileDetailsStackView, after: usernameLabel)
        
        profileDetailsStackView.addAndStandardPin(view: aboutTopSeparatorView)
        aboutTopSeparatorView.addHeightConstraint()
        profileDetailsStackView.addSpacing(largeInterItemSpacing, after: aboutTopSeparatorView)
        
        profileDetailsStackView.addAndStandardPin(view: aboutContentLabel, margin: margin)
        profileDetailsStackView.addSpacing(mediumInterItemSpacing, after: aboutContentLabel)
        
        profileDetailsStackView.addAndStandardPin(view: locationContentLabel, margin: margin)
        profileDetailsStackView.addSpacing(largeInterItemSpacing, after: locationContentLabel)
        
        profileDetailsStackView.addAndStandardPin(view: aboutBottomSeparatorView)
        aboutBottomSeparatorView.addHeightConstraint()
    }
    
    private func addButtonsAndSpacing(for viewType: ViewType, to stackView: UIStackView, after previousView: UIView) {
        var lastView: UIView?
        switch viewType {
        case .profile:
            stackView.addAndStandardPin(view: messageUserButton, margin: margin)
            stackView.addSpacing(mediumInterItemSpacing, after: messageUserButton)
            stackView.addAndStandardPin(view: payButton, margin: margin)
            lastView = payButton
        case .personalProfile:
            stackView.addAndStandardPin(view: editProfileButton, margin: margin)
            lastView = editProfileButton
        case .personalProfileReadOnly:
            break
        }
        
        if let view = lastView {
            profileDetailsStackView.addSpacing(giantInterItemSpacing, after: previousView)
            stackView.addSpacing(largeInterItemSpacing, after: view)
        } else {
            stackView.addSpacing(largeInterItemSpacing, after: previousView)
        }
    }
    
    private func addReputationTitle(to container: UIView, below viewToPinToBottomOf: UIView) {
        container.addSubview(reputationTitle)
        
        reputationTitle.leftToSuperview(offset: margin)
        reputationTitle.rightToSuperview(offset: -margin)
        reputationTitle.topToBottom(of: viewToPinToBottomOf, offset: giantInterItemSpacing)
    }
    
    private func addReputationStackView(to container: UIView, below viewToPinToBottomOf: UIView, for viewType: ViewType) {
        container.addSubview(reputationStackView)
        
        reputationStackView.leftToSuperview()
        reputationStackView.rightToSuperview()
        reputationStackView.topToBottom(of: viewToPinToBottomOf, offset: belowTableViewStyleLabelSpacing)
        reputationStackView.bottom(to: container, offset: -66) // eyeballed
        
        reputationStackView.addAndStandardPin(view: reputationTopSeparatorView)
        reputationTopSeparatorView.addHeightConstraint()
        reputationStackView.addSpacing(largeInterItemSpacing, after: reputationTopSeparatorView)
        
        addReputationView(to: reputationStackView)
        
        if viewType.shouldShowRateUserButton {
            reputationStackView.addAndStandardPin(view: rateThisUserButton)
            rateThisUserButton.height(buttonHeight)
        } else {
            reputationStackView.addSpacing(largeInterItemSpacing, after: reputationView.superview!)
        }
        
        reputationStackView.addAndStandardPin(view: reputationBottomSeparatorView)
        reputationBottomSeparatorView.addHeightConstraint()
    }
    
    private func addReputationView(to stackView: UIStackView) {
        let container = UIView()
        container.addSubview(reputationView)
        reputationView.topToSuperview()
        reputationView.widthToSuperview(multiplier: 0.66)
        reputationView.centerXToSuperview(offset: -6) //eyeballed
        reputationView.bottomToSuperview()

        stackView.addAndStandardPin(view: container)
        stackView.addSpacing(margin, after: container)
    }
    
    // MARK: - Action Targets

    @objc private func didTapMessageButton() {
        profileDelegate?.didTapMessage(in: self)
    }

    @objc private func didTapPayButton() {
        profileDelegate?.didTapPay(in: self)
    }

    @objc private func didTapEditProfileButton() {
        personalProfileDelegate?.didTapEditProfile(in: self)
    }

    @objc private func didTapRateUserButton() {
        profileDelegate?.didTapRateUser(in: self)
    }
}
