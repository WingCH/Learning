//
//  MyAppIntent.swift
//  MyAppIntent
//
//  Created by Wing on 17/9/2023.
//  ref: https://zenn.dev/naoya_maeda/articles/51891f1876e12b

import AppIntents

struct MyAppIntent: AppIntent {
    static let title: LocalizedStringResource = "科目一覧ページを開く"
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

