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
}
