//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 03/05/2022.
//

import XCTest

final class FeedViewController {
    
    init(loader: FeedViewControllerTests.LoaderSpy){
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helper
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
