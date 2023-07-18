import UIKit

let kdPayHost = "payment-uat.krewards.com"

var url = URL(string: "https://payment-uat.krewards.com/kdpay-02/aaaaaa")!

print(resolveForKDPay(url: url))
private func resolveForKDPay(url: URL) -> String? {
    guard let urlComponents = URLComponents(string: url.absoluteString),
          urlComponents.host == kdPayHost,
          // e.g:
          // https://payment-uat.krewards.com/kdpay-02/aaaaaa
          // components = ["", "kdpay-02", "aaaaaa"]
          let components = urlComponents.path.components(separatedBy: "/") as? [String],
          components.count == 3
    else {
        return nil
    }

    if components[1] == "kdpay-01" {
        let transRef = components[2]
        return transRef
    } else if components[1] == "kdpay-02" {
        let payCode = components[2]
        return payCode
    }

    return nil
}
