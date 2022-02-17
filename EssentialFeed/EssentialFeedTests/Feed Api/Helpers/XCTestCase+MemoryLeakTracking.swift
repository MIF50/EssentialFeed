//
//  XCTestCase+MomeryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by MIF50 on 05/02/2022.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated.potential memory leak",file: file,line: line)
        }
    }
}
