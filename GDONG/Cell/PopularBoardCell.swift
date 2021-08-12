//
//  PopularBoardCell.swift
//  GDONG
//
//  Created by 이연서 on 2021/07/15.
//

import UIKit

class PopularBoardCell: UICollectionViewCell {

    @IBOutlet var boardImageView: UIImageView!
    @IBOutlet var boardtitleLabel: UILabel!
    @IBOutlet var chatpeopleLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        boardImageView.layer.cornerRadius = 13
        
        //self.backgroundColor = UIColor(displayP3Red: 240/255, green: 248/255, blue: 255/255, alpha: 1)
        
        //self.layer.cornerRadius = 15
        
        
        super.awakeFromNib()
        // Initialization code
    }

}
