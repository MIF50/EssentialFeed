//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let data = anyData()
        
        sut.save(data: data,for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data,for: url)])
    }
    
    func test_saveImageDataForURL_failOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut,toCompleteWith: failed(),when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveImageDataForURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataStore? = LocalFeedImageDataStore(store: store)
        
        var capturedResult = [LocalFeedImageDataStore.SaveResult]()
        sut?.save(data: anyData(), for: anyURL()) { capturedResult.append($0) }
        
        sut = nil
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(capturedResult.isEmpty,"Expected no received results after instance has been deallocated")
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataStore, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataStore(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataStore,
        toCompleteWith expectedResult: LocalFeedImageDataStore.SaveResult,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        
        sut.save(data: anyData(), for: anyURL()) { recievedResult in
            switch (expectedResult,recievedResult) {
            case (.success,.success): break
                
            case let (.failure(expectedError as LocalFeedImageDataStore.SaveError),.failure(receivedError as LocalFeedImageDataStore.SaveError)):
                XCTAssertEqual(expectedError, receivedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), but got \(recievedResult) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataStore.SaveResult {
        .failure(LocalFeedImageDataStore.SaveError.failed)
    }
}
