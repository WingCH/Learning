
import Combine

let myPublisher = PassthroughSubject<String, Never>()
var subscriptions = Set<AnyCancellable>()

myPublisher.sink { _ in
    print("Completion")
} receiveValue: { value in
    print("Received value ", value)
}

//myPublisher.send(completion: .finished)
myPublisher.send("Hello, Combine!")

//subscriptions.removeAll()

myPublisher.send("Hello, Combine!")
