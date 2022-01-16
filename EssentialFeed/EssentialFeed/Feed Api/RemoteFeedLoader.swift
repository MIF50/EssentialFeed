//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 15/01/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}
public protocol HTTPClient {
    func get(from url: URL,completion: @escaping ((HTTPClientResult)-> Void))
}

public class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Error)-> Void)) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
