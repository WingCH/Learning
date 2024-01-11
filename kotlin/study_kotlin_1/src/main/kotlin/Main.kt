package org.example

import kotlinx.coroutines.*

//TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or
// click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
fun main() {
    val name = "Kotlin"
    //TIP Press <shortcut actionId="ShowIntentionActions"/> with your caret at the highlighted text
    // to see how IntelliJ IDEA suggests fixing it.
    println("Hello, $name!")

    println("1")
    runBlocking { test1().await() }
    println("2")
}

fun test1() = GlobalScope.async { // this: CoroutineScope
    launch {
        delay(1000L) // non-blocking delay for 1 second (default time unit is ms)
        println("World!")
        println(Thread.currentThread().name)

    }
    println("Hello")
    print(Thread.currentThread().name)
}