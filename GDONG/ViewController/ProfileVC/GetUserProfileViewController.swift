//
//  GetUserProfileViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/06/29.
//

import UIKit

class GetUserProfileViewController: UIViewController {
    
    @IBOutlet var userimage: UIImageView!
    @IBOutlet var isSellerBt: UIButton!
    @IBOutlet var followBt: UIButton!
    @IBOutlet var boardTableView: UITableView!
    @IBOutlet var username: UILabel!
    
    var userInfo = ""
    var contents = [Board]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let index = boardTableView.indexPathForSelectedRow else {
            return
        }

        if let detailVC = segue.destination as? DetailNoteViewController {
            detailVC.oneBoard = contents[index.row]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       print(userInfo)
        
        // 테이블뷰와 테이블뷰 셀인 xib 파일과 연결
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)

        boardTableView.register(nibName, forCellReuseIdentifier: "productCell")
        
        boardTableView.delegate = self
        boardTableView.dataSource = self
    }
    

}

extension GetUserProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! TableViewCell
        guard contents.indices.contains(indexPath.row) else { return cell }

        cell.productNameLabel.text = contents[indexPath.row].title
        cell.productPriceLabel.text = "\(contents[indexPath.row].price ?? 0)"
        let date: Date = DateUtil.parseDate((contents[indexPath.row].createdAt!))
        let dateString: String = DateUtil.formatDate(date)
        
        cell.timeLabel.text = dateString
    
        cell.peopleLabel.text = "\(contents[indexPath.row].nowPeople ?? 0)/ \(contents[indexPath.row].needPeople ?? 0)"

        let indexImage =  contents[indexPath.row].images![0]
        let urlString = Config.baseUrl + "/static/\(indexImage)"
    
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
            cell.productImageView.sd_setImage(with: myURL, completed: nil)
        }
        
        return cell
    }
    
    // 디테일뷰 넘어가는 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "detail", sender: nil)
        
    }
}
