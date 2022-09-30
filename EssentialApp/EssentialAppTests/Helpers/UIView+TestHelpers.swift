//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 30/09/2022.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
