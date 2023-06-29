import UIKit

print("A")
let b = await createTask()
print(b)
print("B")

@MainActor
func createTask() async -> String {
    sleep(5)
    return "a"
}
