//
//  HealthKitView.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import BackgroundTasks
import HealthKit
import SwiftUI

struct HealthKitView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = Model()
    @State private var onFirstAppear = true
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("HealthKit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
            Text(model.requestHealthDataAccessResult)
                .multilineTextAlignment(.center)
                .font(.subheadline)
            Button {
                model.requestHealthDataAccessIfNeeded()
            } label: {
                Text("RequestHealth Access")
            }.buttonStyle(.bordered)

            Button {
                model.getLastWeekStepData()
            } label: {
                Text("Get Last Week Step Data")
            }.buttonStyle(.bordered)

            Text(model.stepDataDescription)
            List {
                ForEach(model.stepDataList, id: \.uuid) { step in
                    VStack(alignment: .leading) {
                        Text(step.quantity.doubleValue(for: .count()).queryValue)
                            .font(.title3)
                        Text(step.startDate.description + " to " + step.endDate.description)
                    }
                }
            }
        }.onAppear {
            if onFirstAppear {
                model.requestHealthDataAccessIfNeeded()
                onFirstAppear = false
            }
        }
    }
}

extension HealthKitView {
    class Model: ObservableObject {
        let supabaseManager = SupabaseManager.shared
        let healthData = HealthData()
        @Published var requestHealthDataAccessResult: String = ""
        @Published var stepDataList: [HKQuantitySample] = []
        @Published var stepDataDescription: String = ""

        func requestHealthDataAccessIfNeeded() {
            HealthData.requestHealthDataAccessIfNeeded { [weak self] success in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if success {
                        self.requestHealthDataAccessResult = "HealthKit authorization request was successful!"
                    } else {
                        self.requestHealthDataAccessResult = "HealthKit authorization was not successful."
                    }
                }
            }
        }

        func getLastWeekStepData() {
            Task { @MainActor in
                do {
                    let result = try await healthData.getLastWeekStepData()
                    stepDataList = result
                    stepDataDescription = "Received \(result.count) step data."
                } catch {
                    stepDataDescription = "Error: \(error)"
                }
            }
        }
    }
}

#Preview {
    HealthKitView()
}
