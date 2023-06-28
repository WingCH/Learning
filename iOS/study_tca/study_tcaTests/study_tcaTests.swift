//
//  study_tcaTests.swift
//  study_tcaTests
//
//  Created by Wing on 22/6/2023.
//

import ComposableArchitecture
@testable import study_tca
import XCTest

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testTimer() async {
        let clock = TestClock()

        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTick) {
            $0.count = 1
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTick) {
            $0.count = 2
        }
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }

    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number." }
        }
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(.factResponse("0 is a good number."), timeout: .seconds(1)) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
