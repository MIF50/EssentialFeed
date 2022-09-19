//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 15/09/2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    
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
    ) -> (sut: FeedImageDataLoaderWithFallbackComposite,primary: FeedImageLoaderSpy,fallback: FeedImageLoaderSpy) {
        let primaryLoader = FeedImageLoaderSpy()
        let fallbackLoader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader,fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file: file,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,primaryLoader,fallbackLoader)
    }
}
