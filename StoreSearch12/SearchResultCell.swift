//
//  SearchResultCell.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/21/20.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var artworkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
