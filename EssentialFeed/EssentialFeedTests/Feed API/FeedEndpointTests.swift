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
        
        XCTAssertEqual(received.scheme, "http","scheme")
        XCTAssertEqual(received.host, "a-url.com","host")
        XCTAssertEqual(received.path, "/v1/feed","path")
        XCTAssertEqual(received.query, "limit=10","query")
    }
}

