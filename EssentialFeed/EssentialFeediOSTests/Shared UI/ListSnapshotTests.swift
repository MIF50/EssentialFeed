//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 27/11/2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {
    
    func test_listFeed() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "LIST_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "LIST_FEED_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(messsage: "his is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ListViewController {
        let bunde = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bunde)
        let sut = storyboard.instantiateInitialViewController() as! ListViewController
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func emptyList() -> [CellController] {
        []
    }
}

