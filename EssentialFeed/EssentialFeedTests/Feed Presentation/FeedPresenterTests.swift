//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import XCTest

class FeedPresenter {
    
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
    
    //MARK: - helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedPresenter,view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }

}
