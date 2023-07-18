import UIKit

let currentTime = Date(timeIntervalSince1970: 1688440133)
let evEntryTime = Date(timeIntervalSince1970: 1688432933)

let diffMinute = Calendar(identifier:.gregorian).dateComponents([.minute], from: currentTime, to: evEntryTime).minute ?? 0
