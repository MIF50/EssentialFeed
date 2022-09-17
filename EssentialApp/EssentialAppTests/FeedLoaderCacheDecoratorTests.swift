//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 17/09/2022.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = LocalFeedLoader.SaveResult
    
    func save(_ feed: [FeedImage],completion: @escaping ((Result)-> Void))
}

final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader,cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.save(feed) { _ in }
            }
            completion(result)
        }
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(result: .success(feed))
        
        expect(sut,toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(result: .failure(anyNSError()))
        
        expect(sut,toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cache = CacheSpy()
        let sut = makeSUT(result: .success(feed),cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)],"Expected to cache feed on loader success")
    }
    
    func test_load_doesNotCacheFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(result: .failure(anyNSError()),cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty,"Expected no cache feed on loader failure")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        result: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader,cache: cache)
        trackForMemoryLeaks(loader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
       
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()
        
        func save(_ feed: [EssentialFeed.FeedImage], completion: @escaping ((FeedCache.Result) -> Void)) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
