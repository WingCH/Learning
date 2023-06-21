import Combine

//let myPublisher = [1, 2, 3, 4, 5].publisher
//
//let mySubscriber = myPublisher
//    .sink { print("Square of received value is \($0)") }
//
//let myPublisher2 = myPublisher
//    .map { $0 * $0 }
//    .sink { print("Square2 of received value is \($0)") }
//

let subject = PassthroughSubject<Int, Never>()


let subscription = subject.sink(
    receiveCompletion: { _ in print("Completed") },
    receiveValue: { print("Received value: \($0)") }
)

let subscription2 = subject.sink(
    receiveCompletion: { _ in print("Completed") },
    receiveValue: { print("Received2 value: \($0)") }
)

// Send each value from array manually
[1, 2, 3, 4, 5].forEach {
    subject.send($0)
}

// Send completion event
subject.send(completion: .finished)

