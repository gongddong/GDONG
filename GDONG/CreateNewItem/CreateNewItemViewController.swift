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
  @IBOutlet weak var toolBar: UIToolbar!
  
  weak var entityCell: EntityCell?
  
  var categorySeugue: UIStoryboardSegue?
  
  //Cell Layout Order
  let cellList = Cells.allCases
  
  //MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
//    tableView.allowsSelection = false
    
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
    
    cellList.forEach {
      let cellNib = UINib(nibName: $0.rawValue, bundle: nil)
      tableView.register(cellNib, forCellReuseIdentifier: $0.rawValue)
    }
  }
  
  @objc func showCategoryViewController() {
    
    let storyboard = UIStoryboard(name: "CategoryTableView", bundle: nil)
      guard let categoryTableViewController = storyboard.instantiateViewController(identifier: "CategoryTableViewController") as? CategoryTableViewController else { fatalError("\(#function)") }
    present(categoryTableViewController, animated: true, completion: nil)
  }
  
  deinit {
    self.categorySeugue = nil
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
    
    if indexPath.row == cellList.count - 1, let cell = cell as? EntityCell {
      cell.textView.delegate = self
    }
    
    return cell
  }
  

  
}

extension CreateNewItemViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // EnticyCell 일때
    if indexPath.row == cellList.count - 1 {
      return 300
    }

    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let selectedCell = tableView.cellForRow(at: indexPath) else { fatalError("\(#function)") }
    
    if selectedCell.reuseIdentifier == Cells.CategoryCell.rawValue {
      print("test")
    }
    
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension CreateNewItemViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    print(#function)
    if textView.textColor == .lightGray {
      textView.text = nil
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard !textView.text.isEmpty else {
      EntityCell.setPlaceHolderText(with: textView)
      return
    }
  }
}
