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
    
    private(set) var receivedMessages = [Message]()

    private var retrievalcompletions = [((FeedImageDataStore.RetrievalResult) -> Void)]()
    private var insertionResult: Result<Void,Error>?
    
    func insert(data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalcompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error,at index: Int = 0 ) {
        retrievalcompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?,at index: Int = 0) {
        retrievalcompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
