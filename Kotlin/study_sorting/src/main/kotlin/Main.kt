package org.example

// gender enum
enum class Gender {
    Female,
    Male
}

enum class County {
    USA,
    HongKong,
    China
}

//Person model
data class Person(val name: String, val age: Int, val gender: Gender, val county: County)

/*
Sort Person objects by country: USA > Hong Kong > China
Then by gender: Males first
Next by age: Descending order
Finally by name: Alphabetical order
 */
fun main() {
    val persons: List<Person> = listOf(
        Person(name = "Amy", age = 10, gender = Gender.Female, county = County.HongKong),
        Person(name = "Ben", age = 10, gender = Gender.Male, county = County.USA),
        Person(name = "Billy", age = 12, gender = Gender.Male, county = County.USA),
        Person(name = "Bella", age = 30, gender = Gender.Female, county = County.USA),
        Person(name = "Cyrus", age = 10, gender = Gender.Male, county = County.HongKong),
        Person(name = "Carol", age = 10, gender = Gender.Female, county = County.China),
        Person(name = "Ambrose", age = 10, gender = Gender.Female, county = County.China),
        )


    /*
    Person(name=Ben, age=10, gender=Male, county=USA)
    Person(name=Billy, age=12, gender=Male, county=USA)
    Person(name=Bella, age=30, gender=Female, county=USA)
    Person(name=Amy, age=10, gender=Female, county=HongKong)
    Person(name=Cyrus, age=10, gender=Male, county=HongKong)
    Person(name=Carol, age=10, gender=Female, county=China)
    Person(name=Ambrose, age=10, gender=Female, county=China)
     */
    val sortedPersons1: List<Person> = persons.sortedWith(
        compareBy<Person> {
            when (it.county) {
                County.USA -> 1
                County.HongKong -> 2
                County.China -> 3
            }
        }
    )

    /*
    Person(name=Ben, age=10, gender=Male, county=USA)
    Person(name=Billy, age=12, gender=Male, county=USA)
    Person(name=Bella, age=30, gender=Female, county=USA)
    Person(name=Cyrus, age=10, gender=Male, county=HongKong)
    Person(name=Amy, age=10, gender=Female, county=HongKong)
    Person(name=Carol, age=10, gender=Female, county=China)
    Person(name=Ambrose, age=10, gender=Female, county=China)
     */
    val sortedPersons2: List<Person> = persons.sortedWith(
        compareBy<Person> {
            when (it.county) {
                County.USA -> 1
                County.HongKong -> 2
                County.China -> 3
            }
        }
            .thenByDescending { it.gender == Gender.Male }
    )


    /*
    Person(name=Billy, age=12, gender=Male, county=USA)
    Person(name=Ben, age=10, gender=Male, county=USA)
    Person(name=Bella, age=30, gender=Female, county=USA)
    Person(name=Cyrus, age=10, gender=Male, county=HongKong)
    Person(name=Amy, age=10, gender=Female, county=HongKong)
    Person(name=Carol, age=10, gender=Female, county=China)
    Person(name=Ambrose, age=10, gender=Female, county=China)
     */
    val sortedPersons3: List<Person> = persons.sortedWith(
        compareBy<Person> {
            when (it.county) {
                County.USA -> 1
                County.HongKong -> 2
                County.China -> 3
            }
        }
            .thenByDescending { it.gender == Gender.Male }
            .thenByDescending { it.age }
    )


    /*
    Person(name=Billy, age=12, gender=Male, county=USA)
    Person(name=Ben, age=10, gender=Male, county=USA)
    Person(name=Bella, age=30, gender=Female, county=USA)
    Person(name=Cyrus, age=10, gender=Male, county=HongKong)
    Person(name=Amy, age=10, gender=Female, county=HongKong)
    Person(name=Ambrose, age=10, gender=Female, county=China)
    Person(name=Carol, age=10, gender=Female, county=China)
     */
    val sortedPersons4: List<Person> = persons.sortedWith(
        compareBy<Person> {
            when (it.county) {
                County.USA -> 1
                County.HongKong -> 2
                County.China -> 3
            }
        }
            .thenByDescending { it.gender == Gender.Male }
            .thenByDescending { it.age }
            .thenBy { it.name }
    )

    println("--sortedPersons1--")
    sortedPersons1.forEach { println(it) }
    println("--sortedPersons2--")
    sortedPersons2.forEach { println(it) }
    println("--sortedPersons3--")
    sortedPersons3.forEach { println(it) }
    println("--sortedPersons4--")
    sortedPersons4.forEach { println(it) }
}


