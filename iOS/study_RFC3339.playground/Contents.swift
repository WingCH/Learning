import Foundation

func convertRFC3339ToDate(_ dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: dateString)
}

// Example usage
let date1 = convertRFC3339ToDate("2024-04-26T04:24:49.390Z")
let date2 = convertRFC3339ToDate("2024-04-16T11:12:17.148962+08:00")

if let date1 = date1 {
    print("Date1: \(date1)")
}

if let date2 = date2 {
    print("Date2: \(date2)")
}

