import Combine
import UIKit
// https://developer.apple.com/documentation/combine/controlling-publishing-with-connectable-publishers

/*
 Received data 1: 1256 bytes. 2024-03-01 09:02:36 +0000
 Received data 2: 1256 bytes. 2024-03-01 09:02:36 +0000
 Received completion 1: finished. 2024-03-01 09:02:36 +0000
 Received completion 2: finished. 2024-03-01 09:02:36 +0000
 */


let url = URL(string: "https://example.com/")!
let connectable = URLSession.shared
    .dataTaskPublisher(for: url)
    .map { $0.data }
    .catch { _ in Just(Data()) }
    .share()
    .makeConnectable()

var cancellables = Set<AnyCancellable>()

connectable
    .sink(receiveCompletion: { print("Received completion 1: \($0). \(Date())") },
          receiveValue: { print("Received data 1: \($0.count) bytes. \(Date())") })
    .store(in: &cancellables)

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    connectable
        .sink(receiveCompletion: { print("Received completion 2: \($0). \(Date())") },
              receiveValue: { print("Received data 2: \($0.count) bytes. \(Date())") })
        .store(in: &cancellables)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    connectable.connect().store(in: &cancellables)
}
