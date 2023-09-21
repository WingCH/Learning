//: [Previous](@previous)

import Foundation

/*
 let myCar: Vehicle = Car() // 🔴 Compile error in Swift 5.7: Use of protocol 'Vehicle' as a type must be written 'any Vehicle'
 let myCar2: any Vehicle = Car() // ✅ No compile error in Swift 5.7
 */

/*
 // 🔴 Compile error in Swift 5.7: Use of protocol 'Vehicle' as a type must be written 'any Vehicle'
 func wash(_ vehicle: Vehicle)  {
     // Wash the given vehicle
 }

 // ✅ No compile error in Swift 5.7
 func wash(_ vehicle: any Vehicle)  {
     // Wash the given vehicle
 }
  */

/*
 // ✅ No compile error when changing the underlying data type
 var myCar: any Vehicle = Car()
 myCar = Bus()
 myCar = Car()

 // ✅ No compile error when returning different kind of concrete type
 func createAnyVehicle(isPublicTransport: Bool) -> any Vehicle {
     if isPublicTransport {
         return Bus()
     } else {
         return Car()
     }
 }

 let myCar2 = createAnyVehicle(isPublicTransport: true)
 myCar2.fillGasTank(with: Diesel())
 // 🔴 Member 'fillGasTank' cannot be used on value of type 'any Vehicle'; consider using a generic constraint instead
 */



//: [Next](@next)
