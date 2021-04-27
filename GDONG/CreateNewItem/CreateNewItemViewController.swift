//
//  CreateNewItemViewController.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/22.
//

import UIKit

enum Cells: String, CaseIterable {
  case PhotoCell
  case TitleCell
  case CategoryCell
  case PriceCell
  case EntityCell
}

class CreateNewItemViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  //Cell Layout Order
  let cellList = Cells.allCases
  
  //MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    regitserCells()
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
  
  // Register cells from Nib
  func regitserCells() {
    
    cellList.forEach { [weak self] in
      let cellNib = UINib(nibName: $0.rawValue, bundle: nil)
      tableView.register(cellNib, forCellReuseIdentifier: $0.rawValue)
    }
  }
  
}

extension CreateNewItemViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellList[indexPath.row].rawValue, for: indexPath)
    return cell
  }
  
  
}

extension CreateNewItemViewController: UITableViewDelegate {
  
}
