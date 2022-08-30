//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import XCTest

class FeedImagePresenter {
    
    init(view: Any) {
        
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSentMessagesToView() {
        let (_,view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty,"Exptected no message to view")
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy {
        
        var messages = [Any]()
    }

}
