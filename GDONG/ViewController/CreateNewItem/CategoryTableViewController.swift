//
//  CategoryTableViewController.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/27.
//

import UIKit


enum ItemCategory: String, CaseIterable {
    case 과일
    case 야채
    case 배달
    case 화장품
    case 음반
    case 해외배송
    case 기타
}

class CategoryTableViewController: UITableViewController {
      
  lazy var itemCategoryList = ItemCategory.allCases

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
    
    return itemCategoryList.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
    
    var content = cell.defaultContentConfiguration()

    content.text = itemCategoryList[indexPath.row].rawValue

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
