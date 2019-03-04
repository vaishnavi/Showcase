//
//  CustomTableViewCell.swift
//  Showcase
//
//  Created by Vaishnavi on 26/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(forItem item: Names) {
        titleLabel.text = item.name
        subtitleLabel.text = item.email
    }
    
   override func prepareForReuse() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        isUserInteractionEnabled = false
    }
}

