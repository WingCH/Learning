//
//  SupabaseManager.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import Foundation
import OSLog
import PostgREST
import Supabase

class SupabaseManager {
    private let logger = Logger()
    static let shared = SupabaseManager()
    var user: User?

    init() {
        Task {
            for await authStateChange in authStateChanges {
                self.user = authStateChange.session?.user
            }
        }
    }

    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ogqbuqxexajleyblwmlp.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ncWJ1cXhleGFqbGV5Ymx3bWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ2NTg4NjQsImV4cCI6MjAzMDIzNDg2NH0.2tBM90LuF5RTtitXyEN-PzrS1JNtJO6Erw8ehFY-Pqc"
    )

    // MARK: Auth
    func getLoginedUser() async -> User? {
        do {
            return try await supabase.auth.user()
        } catch {
            return nil
        }
    }

    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        return supabase.auth.authStateChanges
    }

    func signInAnonymouslyIfNeed() async {
        do {
            if let _ = await getLoginedUser() {
            } else {
                try await supabase.auth.signInAnonymously()
            }
        } catch {}
    }

    func insertData(logData: LogData) async {
        var logData = logData
        logData.extra["memory_usage_in_mb"] = String(describing: formattedMemoryFootprint())
        logData.extra["user"] = user?.id.queryValue ?? "null"
        do {
            try await supabase.from("BackgroundMode").insert(logData).execute()
        } catch {
            logger.log(level: .error, "insertData catch: \(error)")
        }

        logger.log(level: .info, "\(logData.toString())")
    }
}

extension SupabaseManager {
    enum LogType: String, Encodable {
        case lifecycle
        case error
        case backgroundRefreshTask
        case scheduleRefreshNormalTask
    }

    struct LogData: Encodable {
        var type: LogType
        var extra: [String: String]

        init(type: LogType, extra: [String: String]) {
            self.type = type
            self.extra = extra
        }

        func toString() -> String {
            return """
            type: \(type)
            extra: \(extra)
            """
        }
    }

    // https://stackoverflow.com/a/64893753/5588637
    func memoryFootprint() -> Float? {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return nil }

        let usedBytes = Float(info.phys_footprint)
        return usedBytes
    }

    func formattedMemoryFootprint() -> String {
        let usedBytes: UInt64? = UInt64(self.memoryFootprint() ?? 0)
        let usedMB = Double(usedBytes ?? 0) / 1024 / 1024
        return String(describing: usedMB)
    }
}
