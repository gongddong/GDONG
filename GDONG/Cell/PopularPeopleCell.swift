//
//  PopularPeopleCell.swift
//  GDONG
//
//  Created by 이연서 on 2021/07/10.
//

import UIKit

class PopularPeopleCell: UICollectionViewCell {

    @IBOutlet var profileimageView: UIImageView!
        
    @IBOutlet weak var peolenameLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        profileimageView.layer.cornerRadius = profileimageView.frame.width/2
        profileimageView.clipsToBounds = true
        
        super.awakeFromNib()
        // Initialization code
    }

}
