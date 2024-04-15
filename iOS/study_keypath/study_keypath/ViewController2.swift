//
//  ViewController2.swift
//  study_keypath
//
//  Created by Wing on 15/4/2024.
//

import Foundation
import UIKit

class ViewControlle2: UIViewController {
    struct Person {
        var name: String
        var age: Int
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        // After dismiss, Open Debug Memory Graph will see Swift.WritableKeyPath<study_keypath.ViewControlle2.Person, Swift.String>
        // KeyPath instances are cached on first use and remain in memory until the end of the program.
        // https://forums.swift.org/t/does-keypath-produce-memory-leaks/64050/2
        let person = Person(name: "John Doe", age: 30)
        let keyPath1 = \Person.name

        print("keyPath1: \(keyPath1)")
        print("person[keyPath: keyPath1]: \(person[keyPath: keyPath1])")
    }
}
