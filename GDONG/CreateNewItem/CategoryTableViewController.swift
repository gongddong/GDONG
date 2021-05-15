//
//  CategoryTableViewController.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/27.
//

import UIKit

enum Category: String, CaseIterable {
    case 배달음식
    case 가공식품
    case 뷰티미용
    case 기타
}

class CategoryTableViewController: UITableViewController {
      
  lazy var categoryList = Category.allCases

  var previousVC: CreateNewItemViewController?

  private(set) var selectedCategory: String? = nil {
    didSet {
      guard let previousVC = previousVC else { return }
      previousVC.categoryLabel.text = selectedCategory
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self

  }

  @IBAction func backButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return categoryList.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
    
    var content = cell.defaultContentConfiguration()

    content.text = categoryList[indexPath.row].rawValue

    cell.contentConfiguration = content
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let cell = tableView.cellForRow(at: indexPath)!
    
    guard let content = cell.contentConfiguration as? UIListContentConfiguration else {
      print(#function)
      return
    }
    
    selectedCategory = content.text
    
    dismiss(animated: true, completion: nil)
  }
}
