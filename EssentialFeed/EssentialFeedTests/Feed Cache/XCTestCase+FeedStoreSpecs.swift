//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 01/04/2022.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
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
    func insert(_ cache:(feed: [LocalFeedImage],timestamp: Date),
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
    
    func expect(_ sut: FeedStore,
                toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
                file: StaticString = #filePath,
                line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut,toRetrieve: expectedResult,file: file,line: line)
    }
    
    func expect(_ sut: FeedStore,
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
}
