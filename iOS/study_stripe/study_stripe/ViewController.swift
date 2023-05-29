//
//  ViewController.swift
//  study_stripe
//
//  Created by Wing on 29/5/2023.
//

import Stripe
import UIKit

class ViewController: UIViewController, STPAuthenticationContext {
    override func viewDidLoad() {
        super.viewDidLoad()

        let cardParams: STPPaymentMethodParams = {
            let cardParams = STPPaymentMethodCardParams()
            cardParams.number = "4242424242424242"
            cardParams.expMonth = 12
            cardParams.expYear = 2025
            cardParams.cvc = "123"
            return STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        }()

        let setupIntentParams = STPSetupIntentConfirmParams(clientSecret: "sk_test_xxxxx")
        setupIntentParams.paymentMethodParams = cardParams

        let paymentHandler = STPPaymentHandler.sharedHandler
        paymentHandler.apiClient = STPAPIClient(publishableKey: "pk_test_xxxxx")
        paymentHandler.confirmSetupIntent(setupIntentParams, with: self) { [weak self] status, _, error in
            guard let self = self else { return }
            switch status {
            case .canceled:
                print("SetupIntent action canceled.")
            case .failed:
                /*
                 some : Error Domain=STPPaymentHandlerErrorDomain Code=10 "There was an unexpected error -- try again in a few seconds" UserInfo={com.stripe.lib:ErrorMessageKey=The provided Intent client secret does not match the expected client secret format. Make sure your server is returning the correct value and that is passed to `STPPaymentHandler`., NSLocalizedDescription=There was an unexpected error -- try again in a few seconds}
                 */
                print("SetupIntent action failed: \(String(describing: error?.localizedDescription))")
            case .succeeded:
                print("SetupIntent action succeeded.")
                DispatchQueue.main.async {
                    // Update UI or navigate to success screen
                }
            @unknown default:
                print("Unknown SetupIntent action status.")
            }
        }
    }

    // MARK: - STPAuthenticationContext
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
