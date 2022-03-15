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
    private let currentDate: (()-> Date)
    
    init(store: FeedStore,currentDate: @escaping (()-> Date)) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.save(items,timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = ((Error?)-> Void)
        
    private var deletionCompletions = [DeletionCompletion]()
        
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem],Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: NSError,at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func save(_ items: [FeedItem],timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed,.insert(items, timestamp)])
    }
    
    // MARK: - Helper
    
    private func makeSUT(
        currentDate: @escaping (()-> Date) = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader,store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store,currentDate: currentDate)
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
