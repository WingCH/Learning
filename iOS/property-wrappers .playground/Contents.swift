// A property wrapper that constrains the wrapped value to be at most 12
@propertyWrapper
struct TwelveOrLess {
    private var number: Int

    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, 12) }
    }

    var projectedValue: String { return "Hi i am projectedValue" }

    init() {
        self.number = 0
    }

    init(wrappedValue: Int) {
        self.number = wrappedValue
    }
}

struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess(wrappedValue: 10) var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height) // 0
print(rectangle.width) // 10
rectangle.height = 20
print(rectangle.height) // 12

print(rectangle.$height)
