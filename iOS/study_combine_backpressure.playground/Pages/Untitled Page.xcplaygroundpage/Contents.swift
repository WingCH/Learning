import Combine
import UIKit
// https://onevcat.com/2019/12/backpressure-in-combine/

/*
 [1,2,3,4,5].publisher.sink(
     receiveCompletion: { completion in
         print("Completion: \(completion)")
     },
     receiveValue: { value in
         print("Receive value: \(value)")
     }
 )

 same
 let publisher = [1,2,3,4,5].publisher
 let subscriber = Subscribers.Sink<Int, Never>(
     receiveCompletion: { completion in
         print("Completion: \(completion)")
     },
     receiveValue: { value in
         print("Receive value: \(value)")
     }
 )
 publisher.subscribe(subscriber)
 */

var buffer = [Int]()
let subscriber = (1...).publisher.print().mySink(
    receiveCompletion: { completion in
        print("Completion: \(completion)")
    },
    receiveValue: { value in
        print("Receive value: \(value)")
        buffer.append(value)
        return buffer.count < 5
    }
)

let cancellable  = Timer.publish(every: 1, on: .main, in: .default)
    .autoconnect()
    .sink { _ in
        buffer.removeAll()
        subscriber.resume()
    }

// 1
extension Subscribers {
    // 2
    class MySink<Input, Failure: Error>: Subscriber, Cancellable, Resumable {
        let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
        let receiveValue: (Input) -> Bool
        // 3
        var subscription: Subscription?
        var shouldPullNewValue: Bool = false
        init(
            receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
            receiveValue: @escaping (Input) -> Bool
        ) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }

        func receive(subscription: Subscription) {
            self.subscription = subscription
//            subscription.request(.unlimited)
            subscription.request(.max(1))
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            shouldPullNewValue = receiveValue(input)
            return shouldPullNewValue ? .max(1) : .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            receiveCompletion(completion)
            subscription = nil
        }

        func cancel() {
            subscription?.cancel()
            subscription = nil
        }

        func resume() {
            guard !shouldPullNewValue else {
                return
            }
            shouldPullNewValue = true
            subscription?.request(.max(1))
        }
    }
}

extension Publisher {
    func mySink(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
//        receiveValue: @escaping (Output) -> Void
        receiveValue: @escaping (Output) -> Bool
    ) -> Cancellable & Resumable {
        let sink = Subscribers.MySink<Output, Failure>(
            receiveCompletion: receiveCompletion,
            receiveValue: receiveValue
        )
        self.subscribe(sink)
        return sink
    }
}

protocol Resumable {
    func resume()
}
