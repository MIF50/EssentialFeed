//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 22/03/2022.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL()-> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any Data".utf8)
}

func makeItemJSON(_ items: [[String: Any]])-> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
