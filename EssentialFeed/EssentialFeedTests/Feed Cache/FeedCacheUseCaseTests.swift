//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 14/03/2022.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.save(items)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = ((Error?)-> Void)
    
    var deleteCachedFeedCallCount = 0
    var insertionCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError,at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func save(_ items: [FeedItem]) {
        insertionCallCount += 1
    }
}

class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteFeedUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertionCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfullDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertionCallCount, 1)
    }
    
    // MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader,store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL()-> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
