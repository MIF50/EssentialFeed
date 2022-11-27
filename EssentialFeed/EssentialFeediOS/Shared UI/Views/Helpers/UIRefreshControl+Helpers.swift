//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
