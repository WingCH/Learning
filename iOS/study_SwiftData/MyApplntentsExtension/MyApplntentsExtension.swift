//
//  MyApplntentsExtension.swift
//  MyApplntentsExtension
//
//  Created by Wing on 1/10/2023.
//

import AppIntents
import UIKit

struct MyApplntentsExtension: AppIntent {
    static var title: LocalizedStringResource = "Add a Date"

    static let description = IntentDescription(
        """
            Description xxxx
        """,
        categoryName: "Date"
    )

    @Parameter(
        title: "date",
        kind: .date
    )
    var date: Date

    @Parameter(title: "Cover Image", description: "An optional image of the book's cover", supportedTypeIdentifiers: ["public.image"])
    var imageFile: IntentFile?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$date) and \(\.$imageFile)")
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let storeIdentifier = try await DataManager.shared.addItem(
            item: Item(timestamp: date, imageData: imageFile?.data)
        )

        print(storeIdentifier)
        let items = try DataManager.shared.fetchItems()
        // if want return custom model, can ref https://github.com/mralexhay/Booky/blob/c2f85f52640257754b2297b2753d870f42a598e4/Shortcuts/Actions/AddBook.swift#L51
        return .result(value: "\(items.map(\.id.storeIdentifier))")
    }
}
