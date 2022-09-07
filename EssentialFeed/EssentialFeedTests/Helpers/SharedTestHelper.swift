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
