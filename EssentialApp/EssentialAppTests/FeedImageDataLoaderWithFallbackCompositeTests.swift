//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 15/09/2022.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader,fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] reuslt in
            switch reuslt {
            case .success:
                completion(reuslt)
                break
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url,completion: completion)
            }
        }
        return task
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotloadImageData() {
        let (_,primaryLoader,fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty,"Expected no loaded URLs on primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty,"Expected no loaded URLs on fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryFirst() {
        let url = anyURL()
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
                
        XCTAssertEqual(primaryLoader.loadedURLs, [url],"Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty,"Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let(sut,primaryLoader,fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url],"Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs,[url],"Expected to load URL from fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTasks() {
        let url = anyURL()
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs,[url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty,"Expected no cancelled URLs in the fallback loader")
    }
    
    func test_cancelLoadImageData_cancelFallbackTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader,fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty,"Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs,[url], "Expected to cancel URL loading from fallback loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimarySuccess() {
        let primaryData = anyData()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success(primaryData), when: {
            primaryLoader.complete(with: primaryData)
        })
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackSuccess() {
        let fallbackData = anyData()
        let (sut, primarLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(fallbackData), when: {
            primarLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        })
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let (sut, primarLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            primarLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        })
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImageDataLoaderWithFallbackComposite,primary: LoaderSpy,fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader,fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file: file,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,primaryLoader,fallbackLoader)
    }
    
    private func expect(
        _ sut:FeedImageDataLoaderWithFallbackComposite,
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
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
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
