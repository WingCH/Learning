import UIKit

print("A")
let b = try await createTask()
print(b)
print("B")

func createTask() async throws -> String {
    let a = Task {
        for i in 0 ... 999 {
            if i == 900 {
                throw NSError(domain: "", code: 1)
            }
            if i == 800 {
                return "'complete in \(i)"
            }
        }
        throw NSError(domain: "", code: 2)
    }
    return try await a.value
}
