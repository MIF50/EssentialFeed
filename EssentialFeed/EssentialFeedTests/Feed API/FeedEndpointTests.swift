//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 17/12/2022.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {

    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://a-url.com")!
        
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://a-url.com/v1/feed")!
        
        XCTAssertEqual(received, expected)
    }
}

