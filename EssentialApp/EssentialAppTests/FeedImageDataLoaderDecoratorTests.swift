//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 18/09/2022.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderDecoratorTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded urls")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load url form loader")
    }
    
    func test_cancelLoadImage_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url],"Expected to cancel URL loading from loader")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData), when:  {
            loader.complete(with: imageData)
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: anyNSError())
        })
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImageDataLoaderDecorator,loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: loader)
        trackForMemoryLeaks(loader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,loader)
    }
    
    private func expect(
        _ sut: FeedImageDataLoaderDecorator,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
       
        let exp = expectation(description: "wait for load completion")
        _  = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult,receivedResult) {
            case let (.success(expectedData),.success(receivedData)):
                XCTAssertEqual(expectedData, receivedData,file: file,line: line)
                
            case let (.failure(expectedError as NSError),.failure(receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError,file: file,line: line)

            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }

    final class LoaderSpy: FeedImageDataLoader {
        
        private(set) var messages = [(url: URL,completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private(set) var cancelledURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
            messages.append((url,completion))
            return Task{ [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with data: Data,at index: Int = 0) {
            messages[index].completion(.success((data)))
        }
        
        func complete(with error: NSError,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        private struct Task: FeedImageDataLoaderTask {
            var callback: (() -> Void)?
            
            func cancel() {
                callback?()
            }
        }
    }
}
