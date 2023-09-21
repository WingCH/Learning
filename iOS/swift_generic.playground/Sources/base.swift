import Foundation

public protocol Vehicle {
    var name: String { get set }

    associatedtype FuelType
    func fillGasTank(with fuel: FuelType)
}

public struct Car: Vehicle {
    public var name = "car"

    public init() {}
    public func fillGasTank(with fuel: Gasoline) {
        print("Fill \(name) with \(fuel.name)")
    }
}

public struct Bus: Vehicle {
    public var name = "bus"

    public init() {}
    public func fillGasTank(with fuel: Diesel) {
        print("Fill \(name) with \(fuel.name)")
    }
}

public struct Gasoline {
    let name = "gasoline"
    public init() {}
}

public struct Diesel {
    let name = "diesel"
    public init() {}
}
