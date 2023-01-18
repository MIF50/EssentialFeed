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
        
        sut.save(data,for: url) { _ in }
        
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
    
    //MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        
        action()

        sut.save(anyData(), for: anyURL()) { recievedResult in
            switch (expectedResult,recievedResult) {
            case (.success,.success): break
                
            case let (.failure(expectedError as LocalFeedImageDataLoader.SaveError),.failure(receivedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(expectedError, receivedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), but got \(recievedResult) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
}
