//
//  ViewCells.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/23.
//

import UIKit

class PhotoPickerCell: UITableViewCell {
  
  @IBOutlet weak var imagePickerButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var photoCountingLabel: UILabel!
//  @IBOutlet weak var photoCell: UICollectionViewCell!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.selectionStyle = .none
    
    let cellNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
    collectionView.register(cellNib, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    
    
  }
}

//MARK: PriceCell
class TitleCell: UITableViewCell {
  
  @IBOutlet weak var titleTextField: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
    }
}

class CategoryCell: UITableViewCell {
  
  @IBOutlet weak var categoryLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}


//MARK: PriceCell
class PriceCell: UITableViewCell {
  
  @IBOutlet weak var priceTextField: UITextField!
  

  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
    //TODO: delegate 설정 가능한지 확인하기
    priceTextField.delegate = self
  }
}

//TODO: UITexFieldDelegate CreateNewItemViewController로 옮기기
extension PriceCell: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

       // Uses the number format corresponding to your Locale
       let formatter = NumberFormatter()
       formatter.numberStyle = .decimal
       formatter.locale = Locale.current
       formatter.maximumFractionDigits = 0


      // Uses the grouping separator corresponding to your Locale
      // e.g. "," in the US, a space in France, and so on
      if let groupingSeparator = formatter.groupingSeparator {

          if string == groupingSeparator {
              return true
          }

          if let textWithoutGroupingSeparator = textField.text?.replacingOccurrences(of: groupingSeparator, with: "") {
              var totalTextWithoutGroupingSeparators = textWithoutGroupingSeparator + string
              if string.isEmpty { // pressed Backspace key
                  totalTextWithoutGroupingSeparators.removeLast()
              }
              if let numberWithoutGroupingSeparator = formatter.number(from: totalTextWithoutGroupingSeparators),
                  let formattedText = formatter.string(from: numberWithoutGroupingSeparator) {

                  textField.text = formattedText
                  return false
              }
          }
      }
      return true
  }
}

class NeedCell: UITableViewCell {
    
    @IBOutlet weak var needTextField: UITextField!
    
    override func awakeFromNib() {
        
      super.awakeFromNib()
        self.selectionStyle = .none
    }
}


class LinkCell: UITableViewCell {
    
    @IBOutlet weak var linkTextfield: UITextField!
    override func awakeFromNib() {
        
      super.awakeFromNib()
        self.selectionStyle = .none
    }
}

class EntityCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
    EntityCell.setPlaceHolderText(with: textView)
  }
  
  // Delegate 에서도 사용하기 위하여 타입 메서드로 선언
  static func setPlaceHolderText(with textView: UITextView) {
    textView.text = "이 곳에 소개하는 글을 적어주세요."
    textView.textColor = .lightGray
  }
}



class BuySellTableViewCell: UITableViewCell {

    @IBOutlet weak var sellButton: UIButton!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func sellButtonAction(_ sender: UIButton) {
        sender.isSelected = true
        buyButton.isSelected = false
        BuySellTableViewCell.ButtonSetting(sender: buyButton)
        BuySellTableViewCell.ButtonSelectedSetting(sender: sender)
        
    }
    
    @IBAction func buyButtonAction(_ sender: UIButton) {
        sender.isSelected = true
        sellButton.isSelected = false
        BuySellTableViewCell.ButtonSetting(sender: sellButton)
        BuySellTableViewCell.ButtonSelectedSetting(sender: sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func ButtonSetting(sender: UIButton){
        sender.backgroundColor = UIColor.white
        sender.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    //눌렀을 때
    static func ButtonSelectedSetting(sender: UIButton){
        sender.backgroundColor = UIColor.darkGray
        sender.setTitleColor(UIColor.white, for: .normal)
    }
    
}


