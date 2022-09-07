//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 03/09/2022.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    func loadImageData(from url: URL,completion: @escaping((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data,response)):
                if response.statusCode == 200 && !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        return task
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion:@escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFutherCompletions() {
            completion = nil
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerfromAnyURLRequest() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "http://url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut,toCompleteWith: .failure(clientError),when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199,300,201,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code,data: anyData(),at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmtpyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non empty data".utf8)
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientsURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://a-give-url.com")!
        
        let task = sut.loadImageData(from: url) { _ in }
        
        XCTAssertTrue(client.cancelledURLs.isEmpty,"Expected no cancelled URL request until task is cancelled")
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url],"Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let emptyData = Data("non empty data".utf8)
        
        var receivedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) {  receivedResult.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: emptyData)
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty,"Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty,"Expected no result after sut instance has been deallocated")
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,client)
    }
    
    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let url = URL(string: "http://a-given-url.com")!
        let exp = expectation(description: "wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file, line: line)
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyData() -> Data {
        Data("any Data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL,completion: (HTTPClient.Result) -> Void)]()
        var cancelledURLs = [URL]()
        
        var requestedURLs: [URL] {
            messages.map {$0.url}
        }
        
        func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
            messages.append((url,completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(withStatusCode code: Int,data: Data,at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success((data,response)))
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        private struct Task: HTTPClientTask {
            let callback: (() -> Void)
            func cancel() {
                callback()
            }
        }
        
    }
}
