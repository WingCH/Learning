//
//  AuthView.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import Auth
import Foundation
import SwiftUI

struct AuthView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = Model()

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Auth")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))

            Text("authStateChange: \(model.authStateChange?.event.rawValue ?? "nil")")
            Text("session: \(String(describing: model.authStateChange?.session?.user))")

            Button {
                model.signInAnonymously()
            } label: {
                Text("signInAnonymously")
            }.buttonStyle(.bordered)
        }.onAppear {
            print("onAppear")
        }
    }
}

extension AuthView {
    class Model: ObservableObject {
        @Published var authStateChange: (event: AuthChangeEvent, session: Session?)? = nil
        let supabaseManager = SupabaseManager.shared

        init() {
            Task { @MainActor in
                for await authStateChange in supabaseManager.authStateChanges {
                    self.authStateChange = authStateChange
                }
            }
        }

        func signInAnonymously() {
            Task {
                await supabaseManager.signInAnonymouslyIfNeed()
            }
        }
    }
}

#Preview {
    RefreshTaskView()
}
