//
//  RxProvider.swift
//  study_rx_to_concurrency
//
//  Created by Wing CHAN on 29/6/2023.
//

import Foundation
import RxCocoa
import RxSwift

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class RxProvider {
    func fetchPosts() -> Observable<[Post]> {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return Observable.error(NSError(domain: "", code: -1, userInfo: nil))
        }
        // generate the request
        let request = URLRequest(url: url)
        // return an Observable
        return URLSession.shared.rx.response(request: request)
            .map { response, data -> [Post] in
                if 200 ..< 300 ~= response.statusCode {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let posts = try? decoder.decode([Post].self, from: data) {
                        return posts
                    } else {
                        throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                    }
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
}
