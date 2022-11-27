//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 27/11/2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "IMAGE_COMMENTS_dight")
    }
    
    //MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ListViewController {
        let bunde = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bunde)
        let sut = storyboard.instantiateInitialViewController() as! ListViewController
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        sut.loadViewIfNeeded()
        return sut
    }
    
    private func comments() -> [CellController] {
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                                             date: "1000 year ago",
                                             username: "a long long long long username.")
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                                             date: "1 day ago",
                                             username: "a username.")
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(message: "Short descriptoin",
                                             date: "1 second ago",
                                             username: "a.")
            )
        ]
    }
}
