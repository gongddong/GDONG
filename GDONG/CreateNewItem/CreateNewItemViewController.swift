//
//  CreateNewItemViewController.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/22.
//

import UIKit

class CreateNewItemViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func backToMainView(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func userDidDoneWriting(_ sender: Any) {
    //TODO: 글 유효성 검사
    let isWritingValid = validateWriting()
    
    guard isWritingValid else { presentAlert(); return }
    
    //TODO: POST & Dismiss
    
    // somePostFunction()
    
    dismiss(animated: true, completion: nil)
  }
  
  // 글 유효성 검사
  func validateWriting() -> Bool {
    
    //tableView.visibleCells 순회하여 isValid 아닌 cell filter
    
    return true
  }
  
  func presentAlert() {
    
    //TODO: message need to be filled with cell's hasValid value
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
  }
}
