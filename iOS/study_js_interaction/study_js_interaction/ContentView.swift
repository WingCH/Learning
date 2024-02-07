//
//  ContentView.swift
//  study_js_interaction
//
//  Created by Wing on 7/2/2024.
//

import JavaScriptCore
import SwiftUI
import NaturalLanguage

struct SegmentDetail: Codable {
    let segment: String
    let index: Int
    let input: String
    let isWordLike: Bool
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button {
                let context = JSContext()
                if let jsFilePath = Bundle.main.path(forResource: "script", ofType: "js"),
                   let jsString = try? String(contentsOfFile: jsFilePath)
                {
                    context?.evaluateScript(jsString)
                }

                
                let text = "19分鐘前 •查看翻譯"
                let languageRecognizer = NLLanguageRecognizer()
                languageRecognizer.processString(text)
                var language = ""
                if let languageCode = languageRecognizer.dominantLanguage?.rawValue {
                    print("Detected language: \(languageCode)")
                    language = languageCode
                } else {
                    print("Unable to detect language")
                }

                if let resultArray = context?.evaluateScript("getSegments('\(language)', '\(text)')") {
                    if let segmentDetails = resultArray.toArray() as? [[String: Any]] {
                        var segments: [SegmentDetail] = []
                        for detail in segmentDetails {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: detail, options: [])
                                let segmentDetail = try JSONDecoder().decode(SegmentDetail.self, from: jsonData)
                                segments.append(segmentDetail)
                            } catch {
                                print("Error decoding a segment detail: \(error)")
                            }
                        }
                        print("Segment details: \(segments)")
                    } else {
                        print("Failed to convert result to array of dictionaries")
                    }
                } else {
                    print("Failed to get segments from JavaScript")
                }
            } label: {
                Text("Click")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
