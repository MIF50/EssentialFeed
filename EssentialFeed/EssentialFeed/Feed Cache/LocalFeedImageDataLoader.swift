//
//  LocalFeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {

    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data: data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
    
    public enum SaveError: Error {
        case failed
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        
        throw LoadError.notFound
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
}
