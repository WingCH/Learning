import Foundation
import XCTest

struct CardIssuer {
    let id: Int
    let cardIinRange: String
}

/**
 Finds the card issuer for a given credit card number by checking it against a list of card issuers with defined IIN ranges.

 - Parameters:
    - cardNumber: The credit card number for which to find the card issuer. This should contain only digits and no spaces or punctuation.
    - cardIssuers: An array of `CardIssuer` instances, each containing the issuer's identification information and IIN range. only support this format: `[300009,400004)`

 - Returns: A matching `CardIssuer` instance if a card issuer with a valid IIN range is found for the provided credit card number or `nil` if no match is found.

 - Note: The `cardNumber` input should have a minimum length of 1 digit. If the input is an empty string or has a length shorter than the minimum required for the IIN range, the function will return `nil`.
 */
func findCardIssuer(for cardNumber: String, cardIssuers: [CardIssuer]) -> CardIssuer? {
    guard !cardNumber.isEmpty else { return nil }
    for issuer in cardIssuers {
        let rangeString = issuer.cardIinRange
        let rangeIndices = rangeString.index(rangeString.startIndex, offsetBy: 1) ..< rangeString.index(rangeString.endIndex, offsetBy: -1)
        let ranges = rangeString[rangeIndices].split(separator: ",").compactMap { Int($0) }
        guard ranges.count == 2 else { return nil }
        let lowerBound = String(ranges[0]).count
        let upperBound = String(ranges[1]).count

        for length in lowerBound ... upperBound {
            let endIndex = min(cardNumber.count, length)
            let startIndex = cardNumber.startIndex
            let cardNumberIndex = cardNumber.index(startIndex, offsetBy: endIndex)
            if let prefix = Int(cardNumber[startIndex ..< cardNumberIndex]) {
                if prefix >= ranges[0], prefix < ranges[1] {
                    return issuer
                }
            }
        }
    }
    return nil
}

class CardIssuerTests: XCTestCase {
    let sampleIssuers: [CardIssuer] = [
        CardIssuer(id: 1, cardIinRange: "[300009,400004)"),
        CardIssuer(id: 2, cardIinRange: "[123456,130099)"),
        CardIssuer(id: 3, cardIinRange: "[2349,39848)"),
        CardIssuer(id: 4, cardIinRange: "[400002,400011)")
    ]

    func testFindCardIssuer() {
        let cardNumber1 = "2330567890123456"
        let result1 = findCardIssuer(for: cardNumber1, cardIssuers: sampleIssuers)
        XCTAssertEqual(result1?.id, 3)

        let cardNumber2 = "3000095678901234"
        let result2 = findCardIssuer(for: cardNumber2, cardIssuers: sampleIssuers)
        XCTAssertEqual(result2?.id, 1)

        let cardNumber3 = "1234567890123456"
        let result3 = findCardIssuer(for: cardNumber3, cardIssuers: sampleIssuers)
        XCTAssertEqual(result3?.id, 2)

        let cardNumber4 = "4001823470852369"
        let result4 = findCardIssuer(for: cardNumber4, cardIssuers: sampleIssuers)
        XCTAssertEqual(result4?.id, 3)

        let cardNumber5 = "1"
        let result5 = findCardIssuer(for: cardNumber5, cardIssuers: sampleIssuers)
        XCTAssertNil(result5)
    }
}

CardIssuerTests.defaultTestSuite.run()
