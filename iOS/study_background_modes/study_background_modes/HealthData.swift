//
//  HealthData.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import Foundation
import HealthKit

class HealthData {
    static let shared = HealthData()
    static let healthStore: HKHealthStore = HKHealthStore()

    // MARK: - Data Types

    static var readDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }

    static var shareDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }

    private static var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue
        ]

        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }

    func getLastWeekStepData() async throws -> [HKQuantitySample] {
        let now = Date()
        let lastWeekStartDate = Calendar.current.date(byAdding: .day, value: -6, to: now)!
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: lastWeekStartDate, end: now)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKQuantitySample] {
                    continuation.resume(returning: samples)
                } else {
                    continuation.resume(throwing: NSError(domain: "HealthDataError", code: -1, userInfo: nil))
                }
            }

            HealthData.healthStore.execute(query)
        }
    }

    func startObservingStepChanges() {
        let supabaseManager = SupabaseManager.shared
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let query: HKObserverQuery = HKObserverQuery(
            sampleType: quantityType,
            predicate: nil,
            updateHandler: { [weak self] _, completionHandler, _ in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let result = try await self.getLastWeekStepData()
                        await supabaseManager.insertData(
                            logData: SupabaseManager.LogData(
                                type: .receivedBackgroundDelivery,
                                extra: [
                                    "lastWeekStepDataCount": result.count.queryValue,
                                ]
                            )
                        )
                    } catch {
                        await supabaseManager.insertData(
                            logData: SupabaseManager.LogData(
                                type: .receivedBackgroundDelivery,
                                extra: [
                                    "error": error.localizedDescription
                                ]
                            )
                        )
                    }
                    completionHandler()
                }
            }
        )

        HealthData.healthStore.execute(query)
        HealthData.healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { success, error in
            Task {
                await supabaseManager.insertData(
                    logData: SupabaseManager.LogData(
                        type: .enableBackgroundDelivery,
                        extra: [
                            "success": success.queryValue,
                            "error": error?.localizedDescription ?? "null"
                        ]
                    )
                )
            }
        }
    }

    // MARK: - Authorization

    /// Request health data from HealthKit if needed, using the data types within `HealthData.allHealthDataTypes`
    class func requestHealthDataAccessIfNeeded(completion: @escaping (_ success: Bool) -> Void) {
        let readDataTypes = Set(allHealthDataTypes)
        let shareDataTypes = Set(allHealthDataTypes)
        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }

    /// Request health data from HealthKit if needed.
    class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                               read readTypes: Set<HKObjectType>?,
                                               completion: @escaping (_ success: Bool) -> Void)
    {
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("Health data is not available!")
        }

        print("Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            if let error = error {
                print("requestAuthorization error:", error.localizedDescription)
            }

            if success {
                print("HealthKit authorization request was successful!")
            } else {
                print("HealthKit authorization was not successful.")
            }

            completion(success)
        }
    }
}
