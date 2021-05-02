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
  @IBOutlet weak var photoPickButton: UIButton!
  
  var imagePickerView: UIImagePickerController = UIImagePickerController()
  
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
//    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
  }
  
  // Register cells from Nib
  func regitserCells() {
    
    cellList.forEach {
      let cellNib = UINib(nibName: $0.rawValue, bundle: nil)
      tableView.register(cellNib, forCellReuseIdentifier: $0.rawValue)
    }
  }
  
  @objc func showImageSourceOption() {
    
    let alertController = UIAlertController(title: "사진을 어디서 가져올까요?", message: nil, preferredStyle: .actionSheet)
    
    // weak self 를 한 이유 : 현재는 발생하지 않지만 인스턴스의 다른 스코프에서 imagePickerAction 의 참조를 얻을 때
    // retain cycle 이 발생할 수 있다.
    let imagePickerAction = UIAlertAction(title: "사진 앨범", style: .default) { [weak self] _ in
      print("showImagePicker()")
      self?.showImagePicker()
    }
    
    alertController.addAction(imagePickerAction)
    
    let cameraAction = UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
      self?.showCamera()
    }
    
    alertController.addAction(cameraAction)
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  func showImagePicker() {
    self.imagePickerView.sourceType = .photoLibrary
    present(self.imagePickerView, animated: true, completion: nil)
  }
  
  func showCamera() {
    self.imagePickerView.sourceType = .camera
    present(self.imagePickerView, animated: true, completion: nil)
  }
  
  deinit {
    
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
    
    let reuseIdentifier = cellList[indexPath.row].rawValue
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    
    switch Cells(rawValue: reuseIdentifier) {
      case .PhotoCell:
        if let cell = cell as? PhotoCell {
          cell.imagePickerButton.addTarget(self, action: #selector(showImageSourceOption), for: .touchUpInside)
          return cell
        }
          
      case .EntityCell:
        if let cell = cell as? EntityCell {
          cell.textView.delegate = self
          return cell
        }
          
      default:
        break
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
