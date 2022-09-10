//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 09/09/2022.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?,Error>
    
    func retrieve(dataForURL url: URL,completion: @escaping ((Result) -> Void))
}

final class LocalFeedImageDataStore: FeedImageDataLoader {
    
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { _ in
            completion(.failure(Error.failed))
        }
        return Task()
    }
    
    public enum Error: Swift.Error {
        case failed
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut,toCompleteWith: failed(),when: {
            let retrievedError = anyNSError()
            store.complete(with: retrievedError)
        })
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        currentData: (() -> Date) = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataStore, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataStore(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataStore,
        toCompleteWith expectedResult: LocalFeedImageDataStore.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        _ = sut.loadImageData(from: anyURL(), completion: { receievedResult in
            switch (receievedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
            case let (.failure(receivedError as LocalFeedImageDataStore.Error),.failure(expectedError as LocalFeedImageDataStore.Error)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("Expected result \(expectedResult), but got \(receievedResult) instead")
            }
            
            exp.fulfill()
        })
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataStore.Result {
        .failure(LocalFeedImageDataStore.Error.failed)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        
        
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private var completions = [((FeedImageDataStore.Result) -> Void)]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.Result) -> Void)) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error,at index: Int = 0 ) {
            completions[index](.failure(error))
        }
    }

}
