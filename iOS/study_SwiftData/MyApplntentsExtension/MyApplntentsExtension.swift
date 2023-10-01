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
    func perform() async throws -> some ReturnsValue<Date> {
        let context = DataManager().modelContainer.mainContext
        var image: UIImage?
        if let imageData = imageFile?.data {
            image = UIImage(data: imageData)
        }
        context.insert(Item(timestamp: date, imageData: image?.jpegData(compressionQuality: 1)))
        try context.save()
        return .result(value: date)
    }
}
