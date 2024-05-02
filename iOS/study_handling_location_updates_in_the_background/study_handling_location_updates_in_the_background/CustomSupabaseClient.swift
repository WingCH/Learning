//
//  CustomLogger.swift
//  study_handling_location_updates_in_the_background
//
//  Created by Wing on 2/5/2024.
//

import Foundation
import OSLog
import PostgREST
import Supabase

class CustomSupabaseClient {
    private let logger = Logger()
    static let shared = CustomSupabaseClient()
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ogqbuqxexajleyblwmlp.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ncWJ1cXhleGFqbGV5Ymx3bWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ2NTg4NjQsImV4cCI6MjAzMDIzNDg2NH0.2tBM90LuF5RTtitXyEN-PzrS1JNtJO6Erw8ehFY-Pqc"
    )

    func insertData(message: String) {
        let dict = [
            "message": message
        ]
        Task {
            do {
                let result = try await supabase.from("CoreLocation").insert(dict).execute()
            } catch {
                print("insertData catch: \(error)")
            }
        }
        logger.log(level: .info, "\(message)")
    }
}
