// Copyright (c) 2018 Token Browser, Inc
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

import UIKit

extension UIViewController {

    // MARK: - Alert Style

    /// Creates and shows an alert with the given title, message, and actions.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - actions: The actions to display and perform with the alert.
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        UIAlertController.alertWith(title: title,
                                    message: message,
                                    actions: actions)?.show(in: self)
    }

    /// Creates and shows an alert with the title "Error" and the given
    /// message, along with an "OK" button to dismiss and perform the optional
    /// action passed in.
    ///
    /// - Parameters:
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    func showErrorOKAlert(message: String?, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        UIAlertController.errorOKAlertWith(message: message,
                                           okActionHandler: okActionHandler)?.show(in: self)
    }

    /// Creates and shows an alert with the title "Error" and the passed-in error's
    /// localized description as the message, along with an "OK" button to dismiss
    /// and perform the optional action passed in.
    ///
    /// - Parameters:
    ///   - error: The error whose `localizedDescription` should be displayed
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    func showErrorOKAlert(error: Error, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        UIAlertController.errorOKAlertWith(error: error,
                                           okActionHandler: okActionHandler)?.show(in: self)
    }

    /// Creates and shows an alert with the given title and message, along with
    /// an "OK" button to dismiss and perform the optional action passed in.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    func showOKOnlyAlert(title: String?, message: String?, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        UIAlertController.okOnlyAlertWith(title: title,
                                          message: message,
                                          okActionHandler: okActionHandler)?.show(in: self)
    }

    /// Creates and shows the account safety alert with predefined actions.
    func showSecurityAlert() {
        let backupAction = UIAlertAction(title: Localized.settings_deposit_error_action_backup, style: .default, handler: { _ in
            let passphraseEnableController = PassphraseEnableController()
            let navigationController = UINavigationController(rootViewController: passphraseEnableController)
            Navigator.presentModally(navigationController)
        })

        showAlert(title: Localized.settings_deposit_error_title,
                  message: Localized.settings_deposit_error_message,
                  actions: [
                    .cancelAction(),
                    backupAction
                  ])
    }

    /// Shows a test alert with the given message, a defined title, and an OK button to dismiss it.
    ///
    /// - Parameter message: The message to display on the alert.
    func showTestAlert(message: String) {
        guard UIApplication.isUITesting else {
            assertionFailure("DON'T CALL THIS IN PROD!")
            return
        }

        showOKOnlyAlert(title: TestOnlyString.testAlertTitle,
                        message: message)
    }

    // MARK: - Action Sheet Style

    /// Creates and shows an action sheet-style alert controller.
    ///
    /// - Parameters:
    ///   - title: The title to display or nil. Defaults to nil.
    ///   - message: The message to display or nil. Defaults to nil.
    ///   - actions: The actions to offer on the action sheet.
    func showActionSheet(title: String? = nil,
                         message: String? = nil,
                         actions: [UIAlertAction]) {
        UIAlertController.actionSheetWith(title: title,
                                          message: message,
                                          actions: actions)?.show(in: self)
    }
}
