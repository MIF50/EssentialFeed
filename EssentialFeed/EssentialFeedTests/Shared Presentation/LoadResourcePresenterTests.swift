//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 03/11/2022.
//

import XCTest
import EssentialFeed

public class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoading_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            return resource + " view model"
        })

        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(resouceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysMessageErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    //MARK: - helper
    
    private func makeSUT(
        mapper: @escaping LoadResourcePresenter.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LoadResourcePresenter,view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(resouceView: view,loadingView: view,errorView: view,mapper: mapper)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,view)
    }
    
    private func localized(
        _ key: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: ResourceView, FeedLoadingView,FeedErrorView {
        
        enum Message: Hashable {
            case display(isLoading: Bool)
            case display(errorMessage: String?)
            case display(resouceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resouceViewModel: viewModel))
        }
    }
}
