//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
        
    func display(_ model: FeedImageViewModel)
}

class FeedImagePresenter  {
    
    private let view: FeedImageView
    private let imageTranformation: ((Data) -> Any?)
    
    init(view: FeedImageView,imageTransformation: @escaping ((Data) -> Any?)) {
        self.view = view
        self.imageTranformation = imageTransformation
    }
    
    func didStartLoadingImageData(for model :FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with data: Data,for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: imageTranformation(data),
            isLoading: false,
            shouldRetry: true)
        )
    }
}

class FeedImagePresenterTests: XCTestCase {
    
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
        let data = Data()
        let (sut, view) = makeSUT(imageTransformation: { _ in nil})
        
        sut.didFinishLoadingImageData(with: data,for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        imageTransformation: @escaping ((Data) -> Any?) = { _ in nil },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view,imageTransformation: imageTransformation)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ model: FeedImageViewModel) {
            messages.append(model)
        }
    }
}
