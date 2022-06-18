//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/06/2022.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onLoadFeed: (([FeedImage]) -> Void)?

    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoadFeed?(feed)
            }
            self?.isLoading = false
        })
    }
}
