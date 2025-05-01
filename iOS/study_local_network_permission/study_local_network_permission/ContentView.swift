//
//  ContentView.swift
//  study_local_network_permission
//
//  Created by Wing CHAN on 5/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var responseText = "未發送請求"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("本地網絡權限測試")
                .font(.largeTitle)
            
            Text("點擊按鈕向本地IP發送 HTTP 請求，以觸發本地網絡權限彈窗")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                isLoading = true
                sendLocalRequest()
            }) {
                Text("發送本地請求")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            
            ScrollView {
                Text(responseText)
                    .padding()
                    .frame(minHeight: 100)
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func sendLocalRequest() {
        // 嘗試連接到本地路由器或設備，會觸發本地網路權限
        if let url = URL(string: "http://192.168.1.1") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.responseText = "請求錯誤: \(error.localizedDescription)"
                    } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        self.responseText = "回應: \(responseString)"
                    } else if let response = response {
                        self.responseText = "收到回應: \(response)"
                    } else {
                        self.responseText = "未收到數據或錯誤"
                    }
                    self.isLoading = false
                }
            }
            task.resume()
            responseText = "請求已發送，等待回應..."
        }
    }
}

#Preview {
    ContentView()
}
