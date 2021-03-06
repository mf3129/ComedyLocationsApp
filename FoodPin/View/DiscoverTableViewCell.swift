//
//  DiscoverTableViewCell.swift
//  FoodPin
//
//  Created by Makan Fofana on 3/15/19.
//  Copyright © 2019 MakanFofana. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mainImageDiscover: UIImageView!
    
    @IBOutlet weak var comedyClubName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
