//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter<ViewSpy,AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
    
    func test_init_doesNotSentMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty,"Exptected no message to view")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysOnRetryFailedImageTransformation() {
        let image = uniqueImage()
        let (sut, view) = makeSUT(imageTransformer: fail)
        
        sut.didFinishLoadingImageData(with: Data(),for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: Data(),for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image,transformedData)
    }
    
    func test_didFinishLoadingImageData_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.image,nil)
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        imageTransformer: @escaping ((Data) -> AnyImage?) = { _ in nil },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ViewSpy,AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view,imageTransformer: imageTransformer)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,view)
    }
    
    struct AnyImage: Equatable {}
    
    private var fail: (Data) -> AnyImage? {
        { _ in nil }
    }
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
