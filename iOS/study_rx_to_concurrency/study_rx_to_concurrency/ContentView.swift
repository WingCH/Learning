//
//  ContentView.swift
//  study_rx_to_concurrency
//
//  Created by Wing CHAN on 29/6/2023.
//

import Combine
import RxCombine
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Published var globeImage: String = "globe"
    @Published var message: String = "Hello, World!"
    @Published var apiResult: String?

    let rxProvider: RxProvider
    let concurrencyProvider: ConcurrencyProvider
    var subscriptions = Set<AnyCancellable>()

    init(rxProvider: RxProvider, concurrencyProvider: ConcurrencyProvider) {
        self.rxProvider = rxProvider
        self.concurrencyProvider = concurrencyProvider
    }

    func callApi() async {
        do {
            let result = try await concurrencyProvider.fetchPosts().value
            apiResult = result.debugDescription
        } catch {
            apiResult = error.localizedDescription
        }
    }

    func callApiWithCombine() {
        rxProvider.fetchPosts()
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("wing debug complete")
            } receiveValue: { [weak self] result in
                self?.apiResult = result.debugDescription
            }.store(in: &subscriptions)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        VStack {
            Image(systemName: viewModel.globeImage)
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(viewModel.message)
            Text(viewModel.apiResult ?? "")
            Button("call api") {
                Task {
                    await viewModel.callApi()
                }
            }
            Button("call api with combine") {
                viewModel.callApiWithCombine()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(rxProvider: RxProvider(), concurrencyProvider: ConcurrencyProvider(rxProvider: RxProvider())))
    }
}
