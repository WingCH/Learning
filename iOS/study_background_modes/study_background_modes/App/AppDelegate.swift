//
//  AppDelegate.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import BackgroundTasks
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var isDidFinishLaunchingWithOptionsTriggered = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        isDidFinishLaunchingWithOptionsTriggered = true
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppConstants.backgroundRefreshTaskIdentifier,
            using: nil
        ) { task in
            Task { [weak self] in
                guard let self else { return }
                await self.refreshNormalTask()
                task.setTaskCompleted(success: true)
                self.scheduleRefreshNormalTask()
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppConstants.backgroundProcessingTaskIdentifier,
            using: nil
        ) { task in
            Task { [weak self] in
                guard let self else { return }
                await self.processNormalTask()
                task.setTaskCompleted(success: true)
                self.scheduleProcessingNormalTask()
            }
        }

        return true
    }

    func startObservingStepChanges() {
        let healthData = HealthData.shared
        healthData.startObservingStepChanges()
    }

    func scheduleRefreshNormalTask() {
        Task {
            let request = BGAppRefreshTaskRequest(
                identifier: AppConstants.backgroundRefreshTaskIdentifier
            )
            request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
            do {
                try BGTaskScheduler.shared.submit(request)
                let supabaseManager = SupabaseManager.shared
                await supabaseManager.insertData(
                    logData: SupabaseManager.LogData(
                        type: .scheduleRefreshNormalTask,
                        extra: [
                            "message": "scheduleRefreshNormalTask"
                        ]
                    )
                )
            } catch {
                let supabaseManager = SupabaseManager.shared
                await supabaseManager.insertData(
                    logData: SupabaseManager.LogData(
                        type: .scheduleRefreshNormalTask,
                        extra: [
                            "error": "Couldn't scheduleRefreshNormalTask \(error.localizedDescription)"
                        ]
                    )
                )
            }
        }
    }

    func scheduleProcessingNormalTask() {
        Task {
            let request = BGProcessingTaskRequest(
                identifier: AppConstants.backgroundProcessingTaskIdentifier
            )
            request.requiresNetworkConnectivity = true
            request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
            do {
                try BGTaskScheduler.shared.submit(request)
                let supabaseManager = SupabaseManager.shared
                await supabaseManager.insertData(
                    logData: SupabaseManager.LogData(
                        type: .scheduleProcessingNormalTask,
                        extra: [
                            "message": "scheduleProcessingNormalTask"
                        ]
                    )
                )
            } catch {
                let supabaseManager = SupabaseManager.shared
                await supabaseManager.insertData(
                    logData: SupabaseManager.LogData(
                        type: .scheduleProcessingNormalTask,
                        extra: [
                            "error": "Couldn't scheduleProcessingNormalTask \(error.localizedDescription)"
                        ]
                    )
                )
            }
        }
    }

    func refreshNormalTask() async {
        let supabaseManager = SupabaseManager.shared
        let healthData = HealthData.shared
        do {
            let lastWeekStepData = try await healthData.getLastWeekStepData()
            await supabaseManager.insertData(
                logData: SupabaseManager.LogData(
                    type: .backgroundRefreshTask,
                    extra: [
                        "isDidFinishLaunchingWithOptionsTriggered": isDidFinishLaunchingWithOptionsTriggered.description,
                        "lastWeekStepDataCount": lastWeekStepData.count.queryValue
                    ]
                )
            )
        } catch {
            await supabaseManager.insertData(
                logData: SupabaseManager.LogData(
                    type: .backgroundRefreshTask,
                    extra: [
                        "isDidFinishLaunchingWithOptionsTriggered": isDidFinishLaunchingWithOptionsTriggered.description,
                        "error": error.localizedDescription
                    ]
                )
            )
        }
    }

    func processNormalTask() async {
        let supabaseManager = SupabaseManager.shared
        let healthData = HealthData.shared
        do {
            let lastWeekStepData = try await healthData.getLastWeekStepData()
            await supabaseManager.insertData(
                logData: SupabaseManager.LogData(
                    type: .backgroundProcessingTask,
                    extra: [
                        "isDidFinishLaunchingWithOptionsTriggered": isDidFinishLaunchingWithOptionsTriggered.description,
                        "lastWeekStepDataCount": lastWeekStepData.count.queryValue
                    ]
                )
            )
        } catch {
            await supabaseManager.insertData(
                logData: SupabaseManager.LogData(
                    type: .backgroundProcessingTask,
                    extra: [
                        "isDidFinishLaunchingWithOptionsTriggered": isDidFinishLaunchingWithOptionsTriggered.description,
                        "error": error.localizedDescription
                    ]
                )
            )
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}
