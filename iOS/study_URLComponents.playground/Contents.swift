import Foundation
import PlaygroundSupport

func handleDeepLink(urlString: String) {
    guard let url = URL(string: urlString),
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          components.host == "example.com"
    else {
        print("無效或不符合要求的 URL")
        return
    }

    let pathComponents = components.path.components(separatedBy: "/").filter { !$0.isEmpty }

    switch pathComponents.count {
    case 2 where pathComponents[0] == "b2b-kdp":
        let couponCode = pathComponents[1]
        print("Type A Deeplink 處理: \(couponCode)")

    case 3 where pathComponents[0] == "b2b-kdp":
        let redeemCodeType = pathComponents[1]
        let redeemCode = pathComponents[2]
        print("Type B Deeplink 處理: \(redeemCodeType), \(redeemCode)")

    default:
        print("不支援的深度連結類型")
    }
}

// 測試不同的深度連結
let typeADeepLink = "https://example.com/b2b-kdp/12345"
let typeBDeepLink = "https://example.com/b2b-kdp/type/67890"
let typeCDeepLink = "https://example.com/b2b-kdp//xxxxx"

handleDeepLink(urlString: typeADeepLink)
handleDeepLink(urlString: typeBDeepLink)
handleDeepLink(urlString: typeCDeepLink)
