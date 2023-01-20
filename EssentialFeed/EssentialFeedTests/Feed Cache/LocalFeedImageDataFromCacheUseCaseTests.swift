//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 09/09/2022.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = try? sut.loadImageData(from: url)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut,toCompleteWith: failed(),when: {
            let retrievedError = anyNSError()
            store.completeRetrieval(with: retrievedError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFoundData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = Data()
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)
        })
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        currentData: (() -> Date) = Date.init,
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
        toCompleteWith expectedResult: Result<Data,Error>,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        
        let receievedResult = Result { try sut.loadImageData(from: anyURL()) }
        switch (receievedResult,expectedResult) {
        case let (.success(receivedData),.success(expectedData)):
            XCTAssertEqual(receivedData, expectedData,file: file,line: line)
            
        case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError),.failure(expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), but got \(receievedResult) instead")
        }
    }
    
    private func notFound() -> Result<Data,Error> {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func failed() -> Result<Data,Error> {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func never(file: StaticString = #filePath, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }
}
