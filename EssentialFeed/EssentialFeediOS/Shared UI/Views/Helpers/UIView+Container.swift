//
//  UIView+Container.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 10/12/2022.
//

import UIKit

extension UIView {
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .red
        container.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
}
