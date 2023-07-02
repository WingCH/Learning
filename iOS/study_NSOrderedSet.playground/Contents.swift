import UIKit

struct A: Hashable {
    let name: String
}

let cardIssuers = [A(name: "A"), A(name: "B"), A(name: "A"), A(name: "C"), A(name: "B")]
//let cardIssuersWithoutDuplicates = Array(NSOrderedSet(array: cardIssuers)) as! [A]


// 有 n2 問題 (時間複雜度)
/*
 假設 n 為 issuers 陣列的大小，對每一個元素進行查找可能需要在最壞情況下遍歷全部 n 個已經存在的元素。因此，對於 n 個元素的循環，檢查是否已存在可能需要 O(n) 的時間。由於我們對每一個元素做這樣的檢查，總的時間複雜度會是 O(n^2)。
 */
var cardIssuersWithoutDuplicates = [A]()
for cardIssuer in cardIssuers {
    if !cardIssuersWithoutDuplicates.contains(where: { $0 == cardIssuer }) {
        cardIssuersWithoutDuplicates.append(cardIssuer)
    }
}
print(cardIssuersWithoutDuplicates)


// 優化的主要目標是降低查找時間複雜度。一種可行的方法是使用 Set 結構來儲存已經存在的發行人，這樣我們就能在常數時間（O（1））中查找元素是否已經存在。但我們仍然需要一個陣列（issuersWithoutDuplicates）來保存發行人的原始順序。此外，我們需要確保 KDPVisaBankIssuer 遵循 Hashable 協議，才能在 Set 中使用它。
//  在優化後的程式碼中，我們使用了 Set 這種數據結構。 Set 使用了一種稱為哈希表（hash table）的數據結構，可以在幾乎所有情況下維護常數時間的成員查找，即 O(1) 的查詢時間。所以，根據這種方法，程式總的時間複雜度會是 O(n)，這顯然比原來的 O(n^2) 快得多。
var issuersWithoutDuplicates = [A]()
var seenIssuers = Set<A>()
for issuer in cardIssuers {
    if seenIssuers.insert(issuer).inserted {
        issuersWithoutDuplicates.append(issuer)
    }
}
print(issuersWithoutDuplicates)
