//
//  myPostViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/30.
//

import UIKit
import Tabman
import Pageboy

class MyPostViewController: TabmanViewController {
    private var viewControllers: Array<UIViewController> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let wroteVC = myWroteViewController()
        let heartVC = myHeartViewController()
        self.navigationItem.title = "내 글 목록"
        
        
        viewControllers.append(wroteVC)
        viewControllers.append(heartVC)
        
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        settingTabBar(ctBar: bar)
        addBar(bar, dataSource: self, at: .top)
          
    }
    
    func settingTabBar(ctBar: TMBar.ButtonBar){
        ctBar.layout.transitionStyle = .snap //customize
        ctBar.layout.contentMode = .fit
        ctBar.backgroundView.style = .blur(style: .extraLight)
        ctBar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        ctBar.layout.interButtonSpacing = 20
        ctBar.buttons.customize({ (button) in
            button.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            button.selectedTintColor = UIColor.black
            
            button.font = UIFont.systemFont(ofSize: 16)
            button.selectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        })
        
        //인디케이터
        ctBar.indicator.weight = .custom(value: 2)
        ctBar.indicator.tintColor = UIColor.black
    }
    
    
    static func ondDayDateText(date: Date) -> String{
        //day Second -> 86400 60*60*24
        let dateFormatter = DateFormatter()
        let fixHour = 24
        let today = Date()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //print("현재 시간 string")
        let nowString = dateFormatter.string(from: today)
        //print(nowString)
    
        //print("현재 시간 date")
    
        var nowDate = dateFormatter.date(from: nowString)

        nowDate = nowDate?.addingTimeInterval(3600 * 9)
        //print(nowDate)
        
        let interval = nowDate!.timeIntervalSince(date) // -> 초만큼으로 환산
        let diffHour = Int(interval / 3600)
        if(diffHour < fixHour){
            return "\(diffHour) 시간 전"
        }
        
        let dateString: String = DateUtil.formatDate(date)
        return dateString
    }
    
    



}

extension MyPostViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        switch index {
        case 0:
            item.title = "내가 쓴 글"
            break
        case 1:
            item.title = "내가 찜한 글"
            break
        default:
            break
        }
        return item
    }
    
    
}


class myWroteViewController: UIViewController {
    var myPostBoard = [Board]()
    
    
    var tableView: UITableView = {
        let tableView = UITableView()
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "productCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let userNickName = UserDefaults.standard.string(forKey: UserDefaultKey.userNickName) else {
            print("UserDefaults has no userNickName")
            return
        }
        
        PostService.shared.getauthorPost(start: -1, author: userNickName, num: 100, completion: {
            response in
            self.myPostBoard = response!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    
    }

    
    


}

extension myWroteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostBoard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! TableViewCell
        guard myPostBoard.indices.contains(indexPath.row) else { return cell }

        cell.productNameLabel.text = myPostBoard[indexPath.row].title
        cell.productPriceLabel.text = "\(myPostBoard[indexPath.row].price ?? 0) 원"
        let date: Date = DateUtil.parseDate(myPostBoard[indexPath.row].updatedAt!)

        cell.timeLabel.text = BuyViewController.ondDayDateText(date: date)
        
        //categoryButton add
        cell.categoryButton.setTitle(myPostBoard[indexPath.row].category, for: .normal)
       
        cell.categoryButton.setTitleColor(UIColor.white, for: .normal)
        cell.categoryButton.backgroundColor = UIColor.darkGray
        cell.categoryButton.layer.cornerRadius = 5
        cell.categoryButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
        cell.peopleLabel.text = "\(myPostBoard[indexPath.row].nowPeople ?? 0) / \(myPostBoard[indexPath.row].needPeople ?? 0)"
        cell.indexPath = indexPath
        let indexImage =  myPostBoard[indexPath.row].images![0]
            //print("index image \(indexImage)")
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.productImageView.sd_setImage(with: myURL, completed: nil)
            }
        cell.moreButton.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}





// ----------- heart post VC -------------------- //
class myHeartViewController: UIViewController {

    var myHeartBoard = [Board]()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "productCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let userNickName = UserDefaults.standard.string(forKey: UserDefaultKey.userNickName) else {
            print("UserDefaults has no userNickName")
            return
        }
        
        
        PostService.shared.getMyHeartPost(nickName: userNickName, completion: { (response) in
            self.myHeartBoard = response!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
  

        
    }

    
    




}

extension myHeartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myHeartBoard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! TableViewCell
        guard myHeartBoard.indices.contains(indexPath.row) else { return cell }

        cell.productNameLabel.text = myHeartBoard[indexPath.row].title
        cell.productPriceLabel.text = "\(myHeartBoard[indexPath.row].price ?? 0) 원"
        let date: Date = DateUtil.parseDate(myHeartBoard[indexPath.row].updatedAt!)

        cell.timeLabel.text = BuyViewController.ondDayDateText(date: date)
        
        //categoryButton add
        cell.categoryButton.setTitle(myHeartBoard[indexPath.row].category, for: .normal)
       
        cell.categoryButton.setTitleColor(UIColor.white, for: .normal)
        cell.categoryButton.backgroundColor = UIColor.darkGray
        cell.categoryButton.layer.cornerRadius = 5
        cell.categoryButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
        cell.peopleLabel.text = "\(myHeartBoard[indexPath.row].nowPeople ?? 0) / \(myHeartBoard[indexPath.row].needPeople ?? 0)"
        cell.moreButton.isHidden = true
        cell.indexPath = indexPath
        let indexImage =  myHeartBoard[indexPath.row].images![0]
            //print("index image \(indexImage)")
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.productImageView.sd_setImage(with: myURL, completed: nil)
            }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
