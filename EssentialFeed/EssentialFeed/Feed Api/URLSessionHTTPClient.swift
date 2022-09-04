//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by MIF50 on 05/02/2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
        
    public func get(from url: URL,completion: @escaping ((HTTPClient.Result)-> Void)) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result(catching: {
                if let error = error {
                   throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data,response)
                } else {
                    throw UnExpectedValuesRepresentation()
                }
            }))
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    private struct UnExpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}
