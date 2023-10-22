import UIKit

struct Person {
    var name: String
    var age: Int
}

var john = Person(name: "John", age: 30)

// 使用 KeyPath 來獲取 name 屬性的值
let nameKeyPath = \Person.name
let johnName = john[keyPath: nameKeyPath]
print(johnName)  // 輸出 "John"

// 使用 KeyPath 來設定 name 屬性的值
john[keyPath: nameKeyPath] = "Jack"
print(john.name)  // 輸出 "Jack"

// 使用 KeyPath 來獲取 age 屬性的值
let ageKeyPath = \Person.age
let johnAge = john[keyPath: ageKeyPath]
print(johnAge)  // 輸出 30

// 使用 KeyPath 來設定 age 屬性的值
john[keyPath: ageKeyPath] = 35
print(john.age)  // 輸出 35
