//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 19/09/2022.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    
    func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for load completion")
        _  = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult,receivedResult) {
            case let (.success(expectedData),.success(receivedData)):
                XCTAssertEqual(expectedData, receivedData,file: file,line: line)
                
            case  (.failure,.failure):
                break
                
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
