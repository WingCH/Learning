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

        scheduleRefreshNormalTask()
        return true
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
                            "error": "Couldn't schedule app refresh \(error.localizedDescription)"
                        ]
                    )
                )
            }
        }
    }

    func refreshNormalTask() async {
        let supabaseManager = SupabaseManager.shared

        await supabaseManager.insertData(
            logData: SupabaseManager.LogData(
                type: .backgroundRefreshTask,
                extra: [
                    "isDidFinishLaunchingWithOptionsTriggered": isDidFinishLaunchingWithOptionsTriggered.description
                ]
            )
        )
    }
}
