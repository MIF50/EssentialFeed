//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 14/03/2022.
//

import XCTest

class LocalFeedLoader {
    
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteFeedUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
