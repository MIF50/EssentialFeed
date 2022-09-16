//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 16/09/2022.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
