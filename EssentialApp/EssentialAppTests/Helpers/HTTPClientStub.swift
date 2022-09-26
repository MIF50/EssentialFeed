//
//  HTTPClientStub.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 26/09/2022.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
    
    private let stub: ((URL) -> HTTPClient.Result)
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
    
    static var offline: HTTPClientStub {
        HTTPClientStub { _ in .failure(NSError(domain: "offline error", code: 0)) }
    }
    
    static func online(stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in  .success(stub(url))}
    }
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
}

