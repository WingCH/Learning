//
//  study_stripeTests.swift
//  study_stripeTests
//
//  Created by Wing CHAN on 5/6/2023.
//

import Stripe
import XCTest

final class study_stripeTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCardNumber() throws {
        let validCardNumber = "4242424242424242"
        let invalidCardNumber = "1111111111111111"
        let incompleteCardNumber = "424242"

        let validCardBrand = STPCardValidator.brand(forNumber: validCardNumber)

        let validValidationResult = STPCardValidator.validationState(forNumber: validCardNumber, validatingCardBrand: true)
        let invalidValidationResult = STPCardValidator.validationState(forNumber: invalidCardNumber, validatingCardBrand: true)
        let incompleteValidationResult = STPCardValidator.validationState(forNumber: incompleteCardNumber, validatingCardBrand: true)

        XCTAssertEqual(validCardBrand, STPCardBrand.visa)
        XCTAssertEqual(validValidationResult, STPCardValidationState.valid)
        XCTAssertEqual(invalidValidationResult, STPCardValidationState.invalid)
        XCTAssertEqual(incompleteValidationResult, STPCardValidationState.incomplete)
    }

    func testExpirationMonth() throws {
        let validMonth = "12"
        let invalidMonth = "43"
        let incompleteMonth = "1"

        let validValidationResult = STPCardValidator.validationState(forExpirationMonth: validMonth)
        let invalidValidationResult = STPCardValidator.validationState(forExpirationMonth: invalidMonth)
        let incompleteValidationResult = STPCardValidator.validationState(forExpirationMonth: incompleteMonth)

        XCTAssertEqual(validValidationResult, STPCardValidationState.valid)
        XCTAssertEqual(invalidValidationResult, STPCardValidationState.invalid)
        XCTAssertEqual(incompleteValidationResult, STPCardValidationState.incomplete)
    }

    func testExpirationYear() throws {
        let validYear = "24"
        let invalidYear = "19"
        let incompleteYear = "2"

        let validValidationResult = STPCardValidator.validationState(forExpirationYear: validYear, inMonth: "12")
        let invalidValidationResult = STPCardValidator.validationState(forExpirationYear: invalidYear, inMonth: "12")
        let incompleteValidationResult = STPCardValidator.validationState(forExpirationYear: incompleteYear, inMonth: "12")

        print(validValidationResult)
        XCTAssertEqual(validValidationResult, STPCardValidationState.valid)
        XCTAssertEqual(invalidValidationResult, STPCardValidationState.invalid)
        XCTAssertEqual(incompleteValidationResult, STPCardValidationState.incomplete)
    }

    func testCVC() throws {
        let validCVC = "123"
        let invalidCVC = "9999"
        let incompleteCVC = "1"

        let validValidationResult = STPCardValidator.validationState(forCVC: validCVC, cardBrand: .visa)
        let invalidValidationResult = STPCardValidator.validationState(forCVC: invalidCVC, cardBrand: .visa)
        let incompleteValidationResult = STPCardValidator.validationState(forCVC: incompleteCVC, cardBrand: .visa)

        XCTAssertEqual(validValidationResult, STPCardValidationState.valid)
        XCTAssertEqual(invalidValidationResult, STPCardValidationState.invalid)
        XCTAssertEqual(incompleteValidationResult, STPCardValidationState.incomplete)
    }
}
