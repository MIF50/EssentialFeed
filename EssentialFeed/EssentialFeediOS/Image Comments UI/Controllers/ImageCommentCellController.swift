//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 27/11/2022.
//

import UIKit
import EssentialFeed

final public class ImageCommentCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.message
        return cell
    }
}
