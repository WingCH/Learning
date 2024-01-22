import UIKit

// https://www.notion.so/wingchhk/RegEx-b47bd8b3c801440b9d1a2c628b3cb1b2?pvs=4
var redirectUrl = "https://abc.com/dl/123-k11"


var redirectUrlFormatReg1 = #"^https:\/\/(abc.com)\/dl\/.*-k11$"#

let result1 = redirectUrl.range(of: redirectUrlFormatReg1, options: .regularExpression)

print(result1)

var redirectUrlFormatReg2 = "^https:\\/\\/(abc.com)\\/dl\\/.*-k11$"

let result2 = redirectUrl.range(of: redirectUrlFormatReg2, options: .regularExpression)

print(result2)


var redirectUrlFormatReg3 = #"^https://abc.com/dl/.*-k11$"#
let result3 = redirectUrl.range(of: redirectUrlFormatReg3, options: .regularExpression)

print(result3)



private func checkB2BForKDP(url: URL) -> Bool {
    let baseHost = "web-hk-uat.krewards.com".replacingOccurrences(of: ".", with: "\\.")
    let urlPatterns = [
        // Matches pattern: https://{baseHost}/b2b-kdp/{coupon_code}
        #"^https:\/\/{HOST}\/b2b-kdp\/[^\/]+$"#,
        // Matches pattern: https://{baseHost}/b2b-kdp/{redeem_code_type}/{redeem_code}
        #"^https:\/\/{HOST}\/b2b-kdp/[^/]+/[^/]+$"#
    ]

    let urlString = url.absoluteString
    let range = NSRange(location: 0, length: (urlString as NSString).length)

    for pattern in urlPatterns {
        let formattedPattern = pattern.replacingOccurrences(of: "{HOST}", with: baseHost)
        if let regex = try? NSRegularExpression(pattern: formattedPattern),
           let match = regex.firstMatch(in: urlString, range: range),
           match.range == range {
            // Perform actions if URL matches B2B pattern
            return true
        }
    }

    return false
}

// test
let url1 = URL(string: "https://web-hk-uat.krewards.com/b2b-kdp/123")!
let url2 = URL(string: "https://web-hk-uat.krewards.com/b2b-kdp/123/456")!
let url3 = URL(string: "https://web-hk-uat.krewards.com/b2b-kdp/123/456/789")!
let url4 = URL(string: "https://web-hk-uat.krewards.com/b2b-kdp/123/456/789/000")!

print(checkB2BForKDP(url: url1))





