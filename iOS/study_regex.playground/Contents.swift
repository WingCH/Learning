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
