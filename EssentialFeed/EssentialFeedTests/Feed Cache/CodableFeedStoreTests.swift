//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 30/03/2022.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEfectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = makeSUT()
        
        insert((feed,timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = makeSUT()
        
        insert((feed,timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid//store.url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let insertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected cache insertion fail with an error")
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperationInOrder = [XCTestExpectation]()
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationInOrder, [op1,op2,op3],"Expected side-effects to run serially but operations finished in wrong order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var receivedError: Error? = nil
        sut.deleteCachedFeed { deletionError in
            receivedError = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    @discardableResult
    private func insert(_ cache:(feed: [LocalFeedImage],timestamp: Date),
                        to sut: FeedStore)-> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        
        var receivedError: Error?
        sut.insert(cache.feed,timestamp: cache.timestamp) { insertionError in
            receivedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut,toRetrieve: expectedResult,file: file,line: line)
    }
    
    private func expect(_ sut: FeedStore,
                        toRetrieve expectedResult: RetrieveCacheFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult,expectedResult) {
                
            case (.empty,.empty),
                (.failure,.failure):
                break
                
            case let (.found(receivedFeed,receivedTimestamp),.found(expectedFeed,expectedTimestamp)):
                XCTAssertEqual(receivedFeed,expectedFeed,file: file,line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp,file: file,line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory()-> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
