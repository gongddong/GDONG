//
//  SearchFilteringViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/26.
//

import UIKit
import DLRadioButton

protocol SearchFilteringDelegate {
    func filteredPosts(filteredPostArray: [Board])
}

class SearchFilteringViewController: UIViewController, UITextFieldDelegate {

    var from: String = ""
    var filteredBoard = [Board]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var recentRadioButton: DLRadioButton!
    
    @IBOutlet weak var viewRadioButton: DLRadioButton!
    
    @IBOutlet weak var heartRadioButton: DLRadioButton!
    
    
    @IBOutlet weak var startPriceTextfield: UITextField!
    
    @IBOutlet weak var endPriceTextfield: UITextField!
    
    @IBOutlet weak var kmTextLabel: UILabel!
    var delegate: SearchFilteringDelegate?
    
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {

        self.view.endEditing(true)

    }

    
   
    @IBOutlet weak var radiusSlide: UISlider!
    
    @IBAction func initial(_ sender: Any) {
        uiSetting()
    }
    
    
    @IBAction func done(_ sender: Any) {
       //selected 된 정렬 방식 찾기
        guard let minPrice:Int = Int(startPriceTextfield.text!) as Int? else {
            return
        }

        let maxPriceText: String?
        
        if endPriceTextfield.text == "" {
            maxPriceText = "1000000000"
        }else {
            maxPriceText = endPriceTextfield.text!
        }
        
        guard let maxPrice: Int = Int(maxPriceText!) as Int? else {
            return
        }
        
        let distValue = Int(radiusSlide.value)
        
        let sortText = find_sortText()

        PostService.shared.filteredPost(start: -1, num: 100, min_price: minPrice, max_price: maxPrice, min_dist: 0, max_dist: distValue, sortby: sortText, completion: { [self] (response) in
                 self.filteredBoard = response

                 self.navigationController?.popViewController(animated: true)

                 let previousVC = self.navigationController?.viewControllers.last as! MainViewController

                 if(self.from == "buy") { // 구매글
                     
                     filteredBoard = filteredBoard.filter { $0.sell == false}
                     print("\(from) 필터링 된 글 \(self.filteredBoard)")
                     let buyVC = previousVC.viewControllers[0] as! BuyViewController
                     buyVC.contents = self.filteredBoard
                     buyVC.filtered = true
                     self.delegate?.filteredPosts(filteredPostArray: self.filteredBoard)
                 }else {
                     filteredBoard = filteredBoard.filter { $0.sell == true}
                     print("\(from) 필터링 된 글 \(self.filteredBoard)")
                     let sellVC = previousVC.viewControllers[0] as! SellViewController
                     sellVC.contents = self.filteredBoard
                     sellVC.filtered = true
                     self.delegate?.filteredPosts(filteredPostArray: self.filteredBoard)
                 }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startPriceTextfield.delegate = self
        endPriceTextfield.delegate = self
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1

        singleTapGestureRecognizer.isEnabled = true

        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        radiusSlide.addTarget(self, action: #selector(onChangeValueSlider(sender:)), for: .valueChanged)


        uiSetting()
        

       

    }
    
    func uiSetting(){
        radiusSlide.minimumValue = 0
        radiusSlide.maximumValue = 5
        radiusSlide.value = 2.5
        recentRadioButton.isSelected = true
        viewRadioButton.isSelected = false
        heartRadioButton.isSelected = false
        startPriceTextfield.text = "0"
        endPriceTextfield.text = ""
        kmTextLabel.text = "동네 범위"
    }
    
    func find_sortText() -> String{
        if(recentRadioButton.isSelected){
            return "postid"
        }else if(viewRadioButton.isSelected){
            return "view"
        }else if(heartRadioButton.isSelected){
            return "likes"
        }
        return "no"
    }
    
    @objc func onChangeValueSlider(sender: UISlider){
        if(sender.value != 0){
            let roundedNum = round(sender.value * 100) / 100
            kmTextLabel.text = "동네 범위 (\(roundedNum)KM)"
            
        }
        
    }
    

    

    

   

}
