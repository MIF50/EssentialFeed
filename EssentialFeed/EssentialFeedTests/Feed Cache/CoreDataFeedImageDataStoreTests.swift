//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(data: Data, for url: URL, completion: @escaping ((FeedImageDataStore.InsertionResult) -> Void)) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        completion(.success(.none))
    }
    
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut,toCompleteRetrieveWith: notFound(),for: anyURL())
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
        let exp = expectation(description: "wait for load completion")
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
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .success(.none)
    }
}
