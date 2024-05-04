//
//  RefreshTaskView.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import BackgroundTasks
import SwiftUI

struct RefreshTaskView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = Model()

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Background Refresh")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))

            Spacer()

            Text("Refresh last performed:")
                .multilineTextAlignment(.center)
                .font(.title)
                .onChange(of: scenePhase) { scenePhase in
                    if scenePhase == .background {
                        print("moved to background")
                    }
                }
                .padding()

            Button {
                model.sendLog()
            } label: {
                Text("debug test")
            }.buttonStyle(.bordered)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    RefreshTaskView()
}

extension RefreshTaskView {
    class Model: ObservableObject {
        let supabaseManager = SupabaseManager.shared
        func sendLog() {
            Task {
                await supabaseManager.insertData(
                    logData: .init(
                        type: .backgroundRefreshTask,
                        extra: ["test": "sendLog"]
                    )
                )
            }
        }
    }
}
