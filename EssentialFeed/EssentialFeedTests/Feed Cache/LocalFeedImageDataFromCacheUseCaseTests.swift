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
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let data = anyData()
        
        sut.save(data: data,for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data,for: url)])
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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = Data()
        
        var capturedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL(), completion: { capturedResults.append($0)} )
        task.cancel()
        
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: foundData)
        
        XCTAssertTrue(capturedResults.isEmpty,"Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataStore? = LocalFeedImageDataStore(store: store)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: { capturedResults.append($0)} )

        sut = nil
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty,"Expected no received results after instance has been deallocated")
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        currentData: (() -> Date) = Date.init,
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
                
            case let (.failure(receivedError as LocalFeedImageDataStore.LoadError),.failure(expectedError as LocalFeedImageDataStore.LoadError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), but got \(receievedResult) instead")
            }
            
            exp.fulfill()
        })
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> LocalFeedImageDataStore.Result {
        .failure(LocalFeedImageDataStore.LoadError.notFound)
    }
    
    private func failed() -> LocalFeedImageDataStore.Result {
        .failure(LocalFeedImageDataStore.LoadError.failed)
    }
    
    private func never(file: StaticString = #filePath, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }
}
