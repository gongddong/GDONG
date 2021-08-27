//
//  RecommendViewController.swift
//  GDONG
//
//  Created by 이연서 on 2021/05/05.
//

import UIKit
import PagingTableView

class RecommendViewController: UIViewController {
    
   
    var sellItemBoard = [Board]()
    var buyItemBoard  = [Board]()
    var otherPeopleLikeItemBoard = [Board]()
    var recommendUser = [Users]()
    var recommendSellUser = [Users]()
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var stackview: UIStackView!
    
    
    @IBOutlet var view1: UIView!
    @IBOutlet var view2: UIView!
    @IBOutlet var view3: UIView!
    @IBOutlet var view4: UIView!
    @IBOutlet var seller: UILabel!
    @IBOutlet var sellerCollectionView: UICollectionView!
    @IBOutlet var buyer: UILabel!
    @IBOutlet var buyerCollectionView: UICollectionView!
    @IBOutlet var buyboard: UILabel!
    @IBOutlet var buyBoardCollectionView: UICollectionView!
    @IBOutlet var sellboard: UILabel!
    @IBOutlet var sellBoardCollectionView: UICollectionView!
    
    @IBOutlet var view5: UIView!
    @IBOutlet var otherpeoplelike: UILabel!
    @IBOutlet var otherpeoplelikeCollectionView: UICollectionView!

    
    
    //당겨서 새로고침시 갱신되어야 할 내용
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        
        self.scrollView.refreshControl?.endRefreshing() // 당겨서 새로고침 종료
        self.sellerCollectionView.reloadData() // Reload하여 뷰를 비워주기
        self.buyerCollectionView.reloadData()
        self.sellBoardCollectionView.reloadData()
        self.buyBoardCollectionView.reloadData()
        self.otherpeoplelikeCollectionView.reloadData()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //판매글
        guard let sellBoardindex = sellBoardCollectionView.indexPathsForSelectedItems?.first else {
            return
        }

        if let sellBoardDetailVC = segue.destination as? DetailNoteViewController {
            sellBoardDetailVC.oneBoard = sellItemBoard[sellBoardindex.row]
        }
        
        //구매글
        guard let buyBoardindex = buyBoardCollectionView.indexPathsForSelectedItems?.first else {
            return
        }

        if let buyBoardDetailVC = segue.destination as? DetailNoteViewController {
            buyBoardDetailVC.oneBoard = buyItemBoard[buyBoardindex.row]
        }
        
        //관심글
        guard let otherBoardindex = otherpeoplelikeCollectionView.indexPathsForSelectedItems?.first else {
            return
        }

        if let otherBoardDetailVC = segue.destination as? DetailNoteViewController {
            otherBoardDetailVC.oneBoard = otherPeopleLikeItemBoard[otherBoardindex.row]
        }
        
        //판매자
        guard let getUserProfileViewController = segue.destination as? GetUserProfileViewController else { return }
        if let sellerindex = sellerCollectionView.indexPathsForSelectedItems?.first {
            getUserProfileViewController.userInfo =  recommendSellUser[sellerindex.row].nickName
        }
        
        //구매자
        guard let getUserProfileViewController = segue.destination as? GetUserProfileViewController else { return }
        if let buyerindex = buyerCollectionView.indexPathsForSelectedItems?.first {
            getUserProfileViewController.userInfo =  recommendUser[buyerindex.row].nickName
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let peopleCellNibName = UINib(nibName: "PopularPeopleCell", bundle: nil)
        let boardCellNibName = UINib(nibName: "PopularBoardCell", bundle: nil)

        sellerCollectionView.register(peopleCellNibName, forCellWithReuseIdentifier: "popularpeoplecell")
        buyerCollectionView.register(peopleCellNibName, forCellWithReuseIdentifier: "popularpeoplecell")
        sellBoardCollectionView.register(boardCellNibName, forCellWithReuseIdentifier: "popularboardcell")
        buyBoardCollectionView.register(boardCellNibName, forCellWithReuseIdentifier: "popularboardcell")
        otherpeoplelikeCollectionView.register(boardCellNibName, forCellWithReuseIdentifier: "popularboardcell")
                
        sellerCollectionView.delegate = self
        sellerCollectionView.dataSource = self
        
        buyerCollectionView.delegate = self
        buyerCollectionView.dataSource = self
        
        
        sellBoardCollectionView.delegate = self
        sellBoardCollectionView.dataSource = self
        
        buyBoardCollectionView.delegate = self
        buyBoardCollectionView.dataSource = self
        
        otherpeoplelikeCollectionView.delegate = self
        otherpeoplelikeCollectionView.dataSource = self
        

        //당겨서 새로고침
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PostService.shared.getRecommendSellPosts(completion: { [self] (response) in
            guard let response = response else {
                return
            }

            //판매 글이 true인 글만 받아오기
            self.sellItemBoard = response.filter {$0.sell == true }
            //판매 글이 false인 글만 받아오기
            self.buyItemBoard = response.filter {$0.sell == false }
            
        })
        
        
        PostService.shared.getOtherPeopleLikePosts(completion: { [self] (response) in
            guard let response = response else {
                return
            }
            
            self.otherPeopleLikeItemBoard = response
            
        })
        
        API.shared.getRecommendUserInfo( completion: { [self] (response) in
            guard let response = response else {
                return
            }
            
            self.recommendUser = response.filter {$0.isSeller == false }
            self.recommendSellUser = response.filter {$0.isSeller == true }
            
        })
        
        
        
        sellerCollectionView.reloadData()
        buyerCollectionView.reloadData()
        sellBoardCollectionView.reloadData()
        buyBoardCollectionView.reloadData()
        otherpeoplelikeCollectionView.reloadData()
        
    }
    
    
    
   
}

extension RecommendViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == sellerCollectionView {
            return recommendSellUser.count
        }
        if collectionView == buyerCollectionView {
            return recommendUser.count
        }
        if collectionView == sellBoardCollectionView {
            return sellItemBoard.count
        }
        if collectionView == buyBoardCollectionView {
            return buyItemBoard.count
        }
        if collectionView == otherpeoplelikeCollectionView {
            return otherPeopleLikeItemBoard.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == sellerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularpeoplecell", for: indexPath) as! PopularPeopleCell
            
            
            guard recommendSellUser.indices.contains(indexPath.row) else { return cell }

            cell.peoplenameLabel.text = recommendSellUser[indexPath.row].nickName
        
        
            let indexImage =  recommendSellUser[indexPath.row].profileImageUrl
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.profileimageView.sd_setImage(with: myURL, completed: nil)
            }
            
            

            return cell
        }

        else if collectionView == buyerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularpeoplecell", for: indexPath) as! PopularPeopleCell
            
            guard recommendUser.indices.contains(indexPath.row) else { return cell }

            cell.peoplenameLabel.text = recommendUser[indexPath.row].nickName
        
        
            let indexImage =  recommendUser[indexPath.row].profileImageUrl
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.profileimageView.sd_setImage(with: myURL, completed: nil)
            }

            return cell
        }

        else if collectionView == sellBoardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell
            
            
            guard sellItemBoard.indices.contains(indexPath.row) else { return cell }

            cell.boardtitleLabel.text = sellItemBoard[indexPath.row].title
        
        
            cell.chatpeopleLabel.text = "참여인원: \(sellItemBoard[indexPath.row].nowPeople ?? 0)/ \(sellItemBoard[indexPath.row].needPeople ?? 0)"

            let indexImage =  sellItemBoard[indexPath.row].images![0]
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.boardImageView.sd_setImage(with: myURL, completed: nil)
            }
            
            

          return cell
        }

        else if collectionView == buyBoardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell

            guard buyItemBoard.indices.contains(indexPath.row) else { return cell }

            cell.boardtitleLabel.text = buyItemBoard[indexPath.row].title
            
        
            cell.chatpeopleLabel.text = "참여인원: \(buyItemBoard[indexPath.row].nowPeople ?? 0)/ \(buyItemBoard[indexPath.row].needPeople ?? 0)"

            let indexImage =  buyItemBoard[indexPath.row].images![0]
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.boardImageView.sd_setImage(with: myURL, completed: nil)
            }
            

            return cell
        }
        
        else if collectionView == otherpeoplelikeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell
            
            guard otherPeopleLikeItemBoard.indices.contains(indexPath.row) else { return cell }

            cell.boardtitleLabel.text = otherPeopleLikeItemBoard[indexPath.row].title
            
        
            cell.chatpeopleLabel.text = "참여인원: \(otherPeopleLikeItemBoard[indexPath.row].nowPeople ?? 0)/ \(otherPeopleLikeItemBoard[indexPath.row].needPeople ?? 0)"

            let indexImage =  otherPeopleLikeItemBoard[indexPath.row].images![0]
            let urlString = Config.baseUrl + "/static/\(indexImage)"
        
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                cell.boardImageView.sd_setImage(with: myURL, completed: nil)
            }

            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if collectionView == sellerCollectionView{

                return CGSize(width: 128, height: 148)
            }
            if collectionView == buyerCollectionView{

                return CGSize(width: 128, height: 148)
            }
            if collectionView == sellBoardCollectionView{

                return CGSize(width: 300, height: 200)
            }
            if collectionView == buyBoardCollectionView{

                return CGSize(width: 300, height: 200)
            }
            if collectionView == otherpeoplelikeCollectionView{

                return CGSize(width: 300, height: 200)
            }
            return CGSize()
          }


        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == sellerCollectionView {
                performSegue(withIdentifier: "userprofile", sender: nil)
            }
            if collectionView == buyerCollectionView {
                performSegue(withIdentifier: "userprofile", sender: nil)
            }
            if collectionView == sellBoardCollectionView {
                performSegue(withIdentifier: "detail", sender: nil)
            }
            if collectionView == buyBoardCollectionView {
                performSegue(withIdentifier: "detail", sender: nil)
            }
            if collectionView == otherpeoplelikeCollectionView {
                performSegue(withIdentifier: "detail", sender: nil)
            }
        }

    
}














