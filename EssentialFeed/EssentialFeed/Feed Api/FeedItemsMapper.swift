//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by MIF50 on 22/01/2022.
//

import Foundation

class FeedItemsMapper: Decodable {
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
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data:Data,from response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root  = try JSONDecoder().decode(FeedItemsMapper.self, from: data)
        return root.models
    }
}
