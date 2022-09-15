//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 15/09/2022.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    init(primary: FeedImageDataLoader,fallback: FeedImageDataLoader) {
        
    }
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        return Task()
    }
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotloadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _  = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader,fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty,"Expected no loaded URLs on primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty,"Expected no loaded URLs on fallback loader")
    }
    
    //MARK: - Helpers
    
    final class LoaderSpy: FeedImageDataLoader {
        
        private(set) var messages = [(url: URL,completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
            messages.append((url,completion))
            return Task()
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {
                
            }
        }
    }
}
