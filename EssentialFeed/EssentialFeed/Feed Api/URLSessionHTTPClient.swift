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
    
    private struct UnExpectedValuesRepresentation: Error {}
    
    public func get(from url: URL,completion: @escaping ((HTTPClient.Result)-> Void)) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnExpectedValuesRepresentation()))
            }
        }.resume()
    }
}
