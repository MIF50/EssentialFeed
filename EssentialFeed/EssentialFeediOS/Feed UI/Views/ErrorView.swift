//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 30/08/2022.
//

import UIKit

public final class ErrorView: UIView {
    
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
