//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut,toCompleteRetrieveWith: notFound(),for: anyURL())
    }
    
    func test_retreiveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-given-url.com")!
        let nonMatchingURL = URL(string: "http://not-match-url.com")!
        
        insert(anyData(),for: url,into: sut)
        
        expect(sut, toCompleteRetrieveWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retreiveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storeData = anyData()
        let url = URL(string: "http://a-url.com")!
        
        insert(storeData, for: url, into: sut)
        
        expect(sut, toCompleteRetrieveWith: found(storeData), for: url)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http://a-url.com")!

        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)
        
        expect(sut, toCompleteRetrieveWith: found(lastStoredData), for: url)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: url, bundle: bundle)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrieveWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for retrieve completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (expectedResult,receivedResult) {
            case let (.success(expectedData),.success(receivedData)):
                XCTAssertEqual(expectedData, receivedData,file: file,line: line)
                
            case let (.failure(expectedError as NSError),.failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult),but got \(receivedResult) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for cache image")
        let image = localImage(for: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
            case .success:
                sut.insert(data: data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        .success(data)
    }
    
    private func localImage(for url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any description", location: "any location", url: url)
    }
}
