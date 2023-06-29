//
//  ConcurrencyProvider.swift
//  study_rx_to_concurrency
//
//  Created by Wing CHAN on 29/6/2023.
//

import Foundation
import RxCocoa
import RxSwift

class ConcurrencyProvider {
    let rxProvider: RxProvider

    init(rxProvider: RxProvider) {
        self.rxProvider = rxProvider
    }

    func fetchPosts() -> Task<[Post], Error> {
        return Task { [weak self] in
            try await withCheckedThrowingContinuation { continuation in
                guard self != nil else { return }
                // TODO: handle disposeBag
                rxProvider.fetchPosts()
                    .subscribe(
                        onNext: { posts in
                            continuation.resume(with: .success(posts))
                        },
                        onError: { error in
                            continuation.resume(with: .failure(error))
                        }
                    )
            }
        }
    }
}
