//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 15/01/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
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
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Result)-> Void)) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, from: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper: Decodable {
    private let items: [Item]
    
    private struct Item : Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id,
                     description:  description,
                     location:  location,
                     imageURL:  image)
        }
    }
    
    var models: [FeedItem] {
        return items.map { $0.item }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data:Data,from response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root  = try JSONDecoder().decode(FeedItemsMapper.self, from: data)
        return root.models
    }
}


