//
//  BuyViewController.swift
//  GDONG
//
//  Created by 이연서 on 2021/05/17.
//

import UIKit
import PagingTableView
import DropDown
import FirebaseFirestore

class BuyViewController: UIViewController, TableViewCellDelegate {
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["게시글 삭제"]
        return dropDown
    }()
    
    
    //delete post 
    func moreButton(cell: TableViewCell) {
        
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 게시글 삭제
                self.alertWithNoViewController(title: "게시글 삭제", message: "게시글을 삭제하시겠습니까?", completion: {(response) in
                    if(response == "OK"){

                    guard let postId = contents[cell.indexPath![1]].postid else {
                        print("cant not find postid")
                        return
                    }


                    checkPostDelete(postId: postId, completed: { (response) in
                        if(response == "OK") { //삭제 할 수 있을 때
                            print("선택한 셀 \(cell.indexPath!)")
                            //post 삭제
                            PostService.shared.deletePost(postId: postId)
                            contents.remove(at: cell.indexPath![1])
                            DispatchQueue.main.async {
                                buyTableView.reloadData()
                            }
                            ChatListViewController().deleteChatRoom(postId: postId)
                            self.alertViewController(title: "삭제 완료", message: "게시글을 삭제하였습니다", completion: { (response) in})
                        }
                    })
                        
                    }
                })
            }
        }
            
    }
        
    func checkPostDelete(postId: Int, completed: @escaping (String)-> (Void)) {
            let document = Firestore.firestore().collection("Chats").document("\(postId)")
            document.getDocument { (document, error) in
                if let document = document, document.exists {

                    guard let users = document.data()!["users"] as? [String] else {
                        print("no users string array in database")
                        return
                    }

                    if(users.count == 1){ //유저가 한명만 남았을 때(방장일때 밖에 없음) 방 삭제
                        print("user count is 1")
                        //채팅방 삭제
                        ChatListViewController().deleteChatRoom(postId: postId)

                        //사람 chatList에서 나가기
                        ChatService.shared.quitChatList(postId: postId)

                        //게시글 삭제
                        PostService.shared.deletePost(postId: postId)
                        completed("OK")
                    }else { // 아직 유저 여러명일때
                        // 글쓴이인경우 == users[0]
                        guard let userEamil = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail) else { return }
                        if(users[0] == userEamil){
                            self.alertViewController(title: "글 삭제 실패", message: "채팅방에 다른 누군가가 있는경우 글을 삭제할 수 없습니다.", completion: {(response) in
                            })
                            completed("NOT OK")
                        }
                        completed("NOT OK")
                    }

                } else {
                    print("Document does not exist")
                }
            }
        }
    
    
    var itemBoard = [Board]()
    //페이징을 위한 새로운 변수 저장
    
    var contents = [Board]()
    var profileImage = [UIImage]()

    @IBOutlet var buyTableView: PagingTableView!
    
    var filtered = false
    
    
    //페이징을 위한 데이터 가공
    let numberOfItemsPerPage = 2 //지정한 개수마다 로딩

      func loadData(at page: Int, onComplete: @escaping ([Board]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          let firstIndex = page * self.numberOfItemsPerPage
          guard firstIndex < self.itemBoard.count else {
            onComplete([])
            return
          }
          let lastIndex = (page + 1) * self.numberOfItemsPerPage < self.itemBoard.count ?
            (page + 1) * self.numberOfItemsPerPage : self.itemBoard.count
            print("last index \(lastIndex)")
          onComplete(Array(self.itemBoard[firstIndex ..< lastIndex]))
        }
      }
    
    
    //당겨서 새로고침시 갱신되어야 할 내용
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        
        self.buyTableView.refreshControl?.endRefreshing() // 당겨서 새로고침 종료
        self.buyTableView.reloadData() // Reload하여 뷰를 비워주기

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    

        if let detailVC = segue.destination as? DetailNoteViewController {
            if let index = buyTableView.indexPathForSelectedRow {
                detailVC.oneBoard = contents[index.row]
            }
            
            
        }
    }
    
    //headerview for filtering
    var HeaderView: UIView = {
        let headerView = UIView()
        var filterButton = UIButton()
        filterButton.setTitle(" 검색 필터", for: .normal)
        filterButton.setImage(UIImage(systemName: "square.fill.text.grid.1x2"), for: .normal)
        filterButton.tintColor = .black
        filterButton.setTitleColor(.black, for: .normal)
        headerView.addSubview(filterButton)
        filterButton.frame = CGRect(x: 280, y: 0, width: 100, height: 50)
        filterButton.addTarget(self, action: #selector(didTapFilteringButton), for: .touchUpInside)
        return headerView
    }()
    
    @objc func didTapFilteringButton(){
        let filteringVC = UIStoryboard.init(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "searchFilter") as! SearchFilteringViewController
        filteringVC.from = "buy"
        filteringVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(filteringVC, animated: true)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // 테이블뷰와 테이블뷰 셀인 xib 파일과 연결
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)

        buyTableView.register(nibName, forCellReuseIdentifier: "productCell")
                
        buyTableView.delegate = self
        buyTableView.dataSource = self
        buyTableView.pagingDelegate = self
        
        
        //당겨서 새로고침
        buyTableView.refreshControl = UIRefreshControl()
        buyTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        HeaderView.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
        buyTableView.tableHeaderView = HeaderView
        

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //필터링 된 글에서 받아온 경우가 아닐 경우
        if filtered == false {
            PostService.shared.getAllPosts(completion: { [self] (response) in
                guard let response = response else {
                    return
                }
                
                //판매 글이 false인 글만 받아오기
                self.contents = response.filter {$0.sell == false }
            })
            buyTableView.reloadData()
        }else {
            print("filtering view controller 글에서 받아온 글 ")
            print(self.contents)
            buyTableView.reloadData()
        }
       
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

extension BuyViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //segmented control 인덱스에 따른 테이블뷰 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("page count \(contents.count)")
        return contents.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myEmail = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! TableViewCell
        cell.delegate = self
        guard contents.indices.contains(indexPath.row) else { return cell }

        cell.productNameLabel.text = contents[indexPath.row].title
        cell.productPriceLabel.text = "\(contents[indexPath.row].price ?? 0) 원"
        
        //내가 쓴 글이 아니라면
        if contents[indexPath.row].email != myEmail {
           cell.moreButton.isHidden = true
            cell.moreButton.isEnabled = false
        }

        let date: Date = DateUtil.parseDate(contents[indexPath.row].updatedAt!)

        cell.timeLabel.text = BuyViewController.ondDayDateText(date: date)
        
        //categoryButton add
        cell.categoryButton.setTitle(contents[indexPath.row].category, for: .normal)
       
        cell.categoryButton.setTitleColor(UIColor.white, for: .normal)
        cell.categoryButton.backgroundColor = UIColor.darkGray
        cell.categoryButton.layer.cornerRadius = 5
        cell.categoryButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
        cell.peopleLabel.text = "\(contents[indexPath.row].nowPeople ?? 0) / \(contents[indexPath.row].needPeople ?? 0)"
        cell.indexPath = indexPath
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
}

//페이징 함수 확장
extension BuyViewController: PagingTableViewDelegate {

  func paginate(_ tableView: PagingTableView, to page: Int) {
    buyTableView.isLoading = true
    self.loadData(at: page) { contents in
        self.contents.append(contentsOf: contents)
    self.buyTableView.isLoading = false
    }
  }

}

