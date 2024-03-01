//: [Previous](@previous)

import Combine
import Foundation

var numberPublisher: Publishers.Sequence<[Int?], Never> = [1, 2, nil, 4, 5].publisher

/*
 receive subscription: ([Optional(1), Optional(2), nil, Optional(4), Optional(5)])
 request unlimited
 receive value: (Optional(1))
 Receive value: Optional(1)
 receive value: (Optional(2))
 Receive value: Optional(2)
 receive value: (nil)
 Receive value: nil
 receive value: (Optional(4))
 Receive value: Optional(4)
 receive value: (Optional(5))
 Receive value: Optional(5)
 receive finished
 Completion: finished

 */
print("--without compactMap--")
numberPublisher
    .print()
    .sink(
        receiveCompletion: { completion in
            print("Completion: \(completion)")
        },
        receiveValue: { value in
            print("Receive value: \(value)")
        }
    )

print("\n\n--with compactMap--")

/*
 receive subscription: ([Optional(1), Optional(2), nil, Optional(4), Optional(5)])
 request unlimited
 receive value: (Optional(1))
 Receive value: 1
 receive value: (Optional(2))
 Receive value: 2
 receive value: (nil)
 request max: (1) (synchronous)
 receive value: (Optional(4))
 Receive value: 4
 receive value: (Optional(5))
 Receive value: 5
 receive finished
 Completion: finished
 */
numberPublisher
    .print()
    .compactMap { $0 }
    .sink(
        receiveCompletion: { completion in
            print("Completion: \(completion)")
        },
        receiveValue: { value in
            print("Receive value: \(value)")
        }
    )
