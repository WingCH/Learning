import UIKit

struct A: Hashable {
    let name: String
}

let cardIssuers = [A(name: "A"), A(name: "B"), A(name: "A"), A(name: "C"), A(name: "B")]
//let cardIssuersWithoutDuplicates = Array(NSOrderedSet(array: cardIssuers)) as! [A]


var cardIssuersWithoutDuplicates = [A]()
for cardIssuer in cardIssuers {
    if !cardIssuersWithoutDuplicates.contains(where: { $0 == cardIssuer }) {
        cardIssuersWithoutDuplicates.append(cardIssuer)
    }
}

print(cardIssuersWithoutDuplicates)
