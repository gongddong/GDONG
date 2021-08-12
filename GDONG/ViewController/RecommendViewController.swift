//
//  RecommendViewController.swift
//  GDONG
//
//  Created by 이연서 on 2021/05/05.
//

import UIKit
import PagingTableView

class RecommendViewController: UIViewController {
    
   
    var itemBoard = [Board]()
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var stackview: UIStackView!
    //@IBOutlet var contentView: UIView!
    
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
        

    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        guard let index = recommendTableView.indexPathForSelectedRow else {
//            return
//        }
//
//        if let detailVC = segue.destination as? DetailNoteViewController {
//            detailVC.oneBoard = itemBoard[index.row]
//        }
//    }
    
    
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
            return 5
        }
        if collectionView == buyerCollectionView {
            return 5
        }
        if collectionView == sellBoardCollectionView {
            return 5
        }
        if collectionView == buyBoardCollectionView {
            return 5
        }
        if collectionView == otherpeoplelikeCollectionView {
            return 5
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == sellerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularpeoplecell", for: indexPath) as! PopularPeopleCell

            cell.profileimageView.image = UIImage(named: "strawberry.jpg")
            cell.peolenameLabel.text = "판매자"

            return cell
        }

        else if collectionView == buyerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularpeoplecell", for: indexPath) as! PopularPeopleCell

            cell.profileimageView.image = UIImage(named: "perfume.jpg")
            cell.peolenameLabel.text = "사용자"

            return cell
        }

        else if collectionView == sellBoardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell

            cell.boardImageView.image = UIImage(named: "bigapple.jpg")
            cell.boardtitleLabel.text = "선착순입니다~"
            cell.chatpeopleLabel.text = "참여인원: "+"1/4"

          return cell
        }

        else if collectionView == buyBoardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell

            cell.boardImageView.image = UIImage(named: "cero.jpg")
            cell.boardtitleLabel.text = "공구해요"
            cell.chatpeopleLabel.text = "참여인원: "+"1/4"

            return cell
        }
        
        else if collectionView == otherpeoplelikeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularboardcell", for: indexPath) as! PopularBoardCell

            cell.boardImageView.image = UIImage(named: "strawberry.jpg")
            cell.boardtitleLabel.text = "관심글입니다"
            cell.chatpeopleLabel.text = "참여인원: "+"1/10"

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


//    // 디테일뷰 넘어가는 함수
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "detail", sender: nil)
//
//    }
//
//
//}
//
//











