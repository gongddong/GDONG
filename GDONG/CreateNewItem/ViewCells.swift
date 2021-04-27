//
//  ViewCells.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/23.
//

import UIKit

class PhotoCell: UITableViewCell {

  @IBAction func AddPhoto(_ sender: UIButton) {
    
    
  }
  override func awakeFromNib() {
      super.awakeFromNib()
    }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

}

//MARK: PriceCell
class TitleCell: UITableViewCell {
  
  override func awakeFromNib() {
      super.awakeFromNib()
    }
}

//MARK: PriceCell
class PriceCell: UITableViewCell {
  
  @IBOutlet weak var priceTextField: UITextField!
  @IBOutlet weak var checkButton: UIButton!
  
  var isAllowedPriceSuggestion: Bool {
    return checkButton.isSelected
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    //TODO: delegate 설정 가능한지 확인하기
    priceTextField.delegate = self
    
    checkButton.tintColor = .lightGray
    checkButton.isSelected = false
  }
  
  @IBAction func checkForPriceSuggestion(_ sender: Any) {
    checkButton.isSelected = checkButton.isSelected ? false : true
    checkButton.tintColor = checkButton.isSelected ? .systemBlue : .lightGray
  }
}

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

//MARK: TextViewCell
class TextViewCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.setPlaceHolderText()
  }
  
  func setPlaceHolderText() {
    textView.text = "이 곳에 글 내용을 입력해주세요"
    textView.textColor = .lightGray
  }
}

extension TextViewCell: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .lightGray {
      textView.text = nil
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard !textView.text.isEmpty else {
      setPlaceHolderText()
      return
    }
  }
}
