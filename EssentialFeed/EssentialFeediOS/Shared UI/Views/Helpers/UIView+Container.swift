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
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor),
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
}
