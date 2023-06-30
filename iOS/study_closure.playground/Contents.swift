import UIKit

func search(havePermission: () -> (Bool)) -> String {
    if havePermission() {
        return "You can search"
    } else {
        return "You can't search"
    }
}

let a = search(havePermission: {
    sleep(5)
    return true
})

print(a)
