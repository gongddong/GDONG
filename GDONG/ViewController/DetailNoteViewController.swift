//
//  DetailNoteViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/21.
//


import UIKit
import FirebaseFirestore



class DetailNoteViewController: UIViewController, UIGestureRecognizerDelegate {
    var oneBoard: Board?
    var postChatRoom: ChatRoom?
    
    @IBOutlet weak var FrameTableView: UITableView!
    
    private var docReference: DocumentReference? //현재 document


    
    var bottomView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemYellow
        var goToChatButton = UIButton()
        goToChatButton.setTitle("채팅 방 가기", for: .normal)
        goToChatButton.setTitleColor(UIColor.white, for: .highlighted)
        goToChatButton.backgroundColor = UIColor.orange
        goToChatButton.layer.cornerRadius = 5
        goToChatButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        goToChatButton.addTarget(self, action: #selector(didTapGoToChatRoom), for: .touchUpInside)
        
        view.addSubview(goToChatButton)
        goToChatButton.frame = CGRect(x: 220, y: 20, width: 150, height: 50)
        return view
    }()
    
    let userNickName = UserDefaults.standard.string(forKey: UserDefaultKey.userNickName)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
        PostService.shared.updateViewCount(postId: (oneBoard?.postid!)!)
        view.addSubview(bottomView)
        bottomView.frame = CGRect(x: 0, y: view.bottom - 100, width: view.width, height: 100)
        
        
        let heartButton = HeartButton(frame: CGRect(x: 50, y: 25, width: 40, height: 40))
            heartButton.addTarget(
              self, action: #selector(didTapHeart(_:)), for: .touchUpInside)
        bottomView.addSubview(heartButton)
        
        //유저 likes 배열에 있는 (좋아요 한 글)이면
        UserService.shared.getUserInfo(completion: { [self] (response) in
            for i in response.likes {
                if i == oneBoard!.postid {
                    print("유저가 좋아요 한 글")
                    print(i)
                    heartButton.setLikeState() // 하트 버튼 ui 누른 상태 setting
                }
            }
        })
        
        // navigaion bar - report button
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(didTapReport))
        
    

    }
    
    func tableViewSetting(){
        FrameTableView.register(TitleTableViewCell.nib(), forCellReuseIdentifier: TitleTableViewCell.identifier)
        FrameTableView.register(ContentTableViewCell.nib(), forCellReuseIdentifier: ContentTableViewCell.identifier)
        FrameTableView.register(LinkTableViewCell.nib(), forCellReuseIdentifier: LinkTableViewCell.identifier)
        FrameTableView.register(PriceAndPeopleTableViewCell.nib(), forCellReuseIdentifier: PriceAndPeopleTableViewCell.identifier)
        FrameTableView.register(ViewAndLikeTableViewCell.nib(), forCellReuseIdentifier: ViewAndLikeTableViewCell.identifier)
        FrameTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        FrameTableView.separatorInset.left = 0

  
        FrameTableView.separatorColor = UIColor.lightGray
        FrameTableView.isEditing = false
        FrameTableView.isScrollEnabled = true
        FrameTableView.allowsSelection = false
        FrameTableView.delegate = self
        FrameTableView.dataSource = self
        FrameTableView.estimatedRowHeight = 80
        FrameTableView.rowHeight = UITableView.automaticDimension
    }
    
    
    @objc func didTapReport(){
        //make with dropDown button
    }
    
    @objc func didTapGoToChatRoom(){
        print("didTapGoToChatRoom")
        //TO-DO
        //if post user 인원 찼을 때
        if(oneBoard!.needPeople! == oneBoard!.nowPeople){
            alertController()
        }else {
            guard let userEmail = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail) else {
                print("no exists user ")
                return
            }
            addUserToChat(userEamil: userEmail, completed: {(response) in
                if(response == "OK"){
                    self.performSegue(withIdentifier: "chatRoom", sender: nil)
                }
            })
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatVC = segue.destination as! ChatViewController
        chatVC.chatRoom = self.postChatRoom
        
    }
    
    func findChatInfo(){
        
    }
    
    func addUserToChat(userEamil: String, completed: @escaping (String) -> Void){
        //getPostInfo
        //postId == chatId
        print("addUserToChat called")
        guard let postId = oneBoard?.postid else {
            print("no post id")
            return
        }
        
        //채팅방에 유저 넣기
        let document = Firestore.firestore().collection("Chats").document("\(postId)")
        print(document.documentID)
        
        document.updateData([
            "users": FieldValue.arrayUnion(["\(userEamil)"])
        ])
        ChatService.shared.joinChatList(postId: postId)
        document.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let ChatRoomName = document.data()!["ChatRoomName"] as? String else {
                    print("no chat room name in database")
                    return
                }
                
                guard let ChatRoomDate = document.data()!["Date"] as? Timestamp else {
                    print("no chat room date in database")
                    return
                }
                

                
                guard let ChatImage = document.data()!["ChatImage"] as? String else {
                    print("no ChatImage string in database")
                    return
                }
                print(ChatRoomName)
                print(ChatRoomDate)
                print(ChatImage)
                
                self.postChatRoom = ChatRoom(chatId: document.documentID, chatRoomName: ChatRoomName, chatRoomDate: Date(timeIntervalSince1970: TimeInterval(ChatRoomDate.seconds)), chatImage: ChatImage)
                //print("postChatRoom ready \(self.postChatRoom)")
                completed("OK")
       
            } else {
                print("Document does not exist")
            }
        }

    }
    
    public func alertController() {
       let AlertVC = UIAlertController(title: "인원 초과", message: "채팅방에 인원이 꽉 찼습니다.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        AlertVC.addAction(OKAction)
        
        self.present(AlertVC, animated: true, completion: nil)
    }
    
    
    @objc func didTapHeart(_ sender: UIButton){
        print("didTapHeart")
        guard let button = sender as? HeartButton else { return }
        if(button.flipLikedState() == true){
            //관심 글 등록 toast message // TO DO post likes
            PostService.shared.clickHeart(postId: oneBoard!.postid!)
            self.showToast(message: "관심 글에 등록되었습니다.", font: .systemFont(ofSize: 12.0))
        }
    }
    //contentView content
    func makeContentView(contentTextView : UITextView) -> NSAttributedString {
        
        let fullString = NSMutableAttributedString()
        
        if(oneBoard!.content != ""){
            fullString.append(NSAttributedString(string: oneBoard!.content!))
            fullString.append(NSAttributedString(string: "\n\n\n"))
           
        }
        guard let images = oneBoard!.images else {
            return NSAttributedString()
        }
 
        for i in images {
            let image1Attachment = NSTextAttachment()
            let urlString = Config.baseUrl + "/static/\(i)"

            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                let data = try? Data(contentsOf: myURL)
                let localImage = UIImage(data: data!)
                image1Attachment.image = localImage
                
                let newImageWidth = (contentTextView.bounds.size.width - 30)
                let scale = newImageWidth/localImage!.size.width
                let newImageHeight = (localImage!.size.height - 30) * scale
                image1Attachment.bounds = CGRect.init(x: 0, y: 300, width: newImageWidth, height: newImageHeight)
               
                image1Attachment.image = UIImage(cgImage: (image1Attachment.image?.cgImage!)!, scale: scale, orientation: .up)
                
                let imgString = NSAttributedString(attachment: image1Attachment)
       
                let fontSize = UIFont.systemFont(ofSize: 15)
                
                
             
                fullString.addAttribute(.font, value: fontSize, range: (contentTextView.text as NSString).range(of: contentTextView.text))
                fullString.append(imgString)
                
            }
        }
        return fullString

    }
        


    }
    




extension DetailNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nomalCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let chatVC = segue.destination as! ChatViewController
//        let index = chatListTableView.indexPathForSelectedRow
//        chatVC.chatRoom = self.mychatRoom[index!.row]

        //titleCell
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier) as! TitleTableViewCell
            
            cell.configure(with: oneBoard!)
            return cell
            
        }else if(indexPath.row == 1){ // content cell
            let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier) as! ContentTableViewCell
            
            cell.contentTextView.attributedText = makeContentView(contentTextView : cell.contentTextView)
            return cell
            
        }else if(indexPath.row == 2){ // link cell
            let cell = tableView.dequeueReusableCell(withIdentifier: LinkTableViewCell.identifier) as! LinkTableViewCell
      
            cell.configure(link: oneBoard!.link!)
           return cell
        }
        else if(indexPath.row == 3){ // price cell
            let cell = tableView.dequeueReusableCell(withIdentifier: PriceAndPeopleTableViewCell.identifier) as! PriceAndPeopleTableViewCell
            cell.configure(price: oneBoard!.price!, nowPeople: oneBoard!.nowPeople!, needPeople: oneBoard!.needPeople!)
           return cell
            
        }else if(indexPath.row == 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: ViewAndLikeTableViewCell.identifier) as! ViewAndLikeTableViewCell
            cell.configure(view: oneBoard!.view!, like: oneBoard!.interest!)
           return cell
        }else if (indexPath.row == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            return cell
        }
        
        return nomalCell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension // default
    }
  
    

    
}

class HeartButton: UIButton {
  private var isLiked = false
  
  private let unlikedImage = UIImage(named: "heart_empty")
  private let likedImage = UIImage(named: "heart")
  
  private let unlikedScale: CGFloat = 0.7
  private let likedScale: CGFloat = 1.3

  override public init(frame: CGRect) {
    super.init(frame: frame)

    setImage(unlikedImage, for: .normal)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func flipLikedState() -> Bool {
    isLiked = !isLiked
    animate()
    return isLiked
  }
    
    public func setLikeState() {
        isLiked = !isLiked
        animate()
    }

  private func animate() {
    UIView.animate(withDuration: 0.1, animations: {
      let newImage = self.isLiked ? self.likedImage : self.unlikedImage
      let newScale = self.isLiked ? self.likedScale : self.unlikedScale
      self.transform = self.transform.scaledBy(x: newScale, y: newScale)
      self.setImage(newImage, for: .normal)
    }, completion: { _ in
      UIView.animate(withDuration: 0.1, animations: {
        self.transform = CGAffineTransform.identity
      })
    })
  }
}
 
