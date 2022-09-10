//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
   
    enum Message: Equatable {
        case insert(data: Data,for: URL)
        case retrieve(dataFor: URL)
    }
    
    private var retrievalcompletions = [((FeedImageDataStore.RetrievalResult) -> Void)]()
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalcompletions.append(completion)
    }
    
    func insert(data: Data, for url: URL, completion: @escaping ((InsertionResult) -> Void)) {
        receivedMessages.append(.insert(data: data, for: url))
    }
    
    func completeRetrieval(with error: Error,at index: Int = 0 ) {
        retrievalcompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?,at index: Int = 0) {
        retrievalcompletions[index](.success(data))
    }
}
