//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/06/2022.
//

import UIKit

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
