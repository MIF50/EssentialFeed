//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 02/12/2022.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable,_ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.datSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
