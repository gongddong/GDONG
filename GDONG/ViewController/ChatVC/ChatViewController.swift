//
//  ChatViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/06/24.
//

import InputBarAccessoryView
import FirebaseFirestore
import MessageKit
import SDWebImage
import PhotosUI

//class ChatViewController: MessagesViewController {
//
//    var messages: [Message] = []
//
//    private var selfSender: Sender? {
//        guard let email = UserDefaults.standard.value(forKey: UserDefaultKey.userEmail) as? String else {
//            return nil
//        }
//
//        return Sender(photoURL: "",
//                      senderId: email,
//                      displayName: "Me")
//    }
//
//    public static let dateFormatter: DateFormatter = {
//        let formattre = DateFormatter()
//        formattre.dateStyle = .medium
//        formattre.timeStyle = .long
//        formattre.locale = .current
//        return formattre
//    }()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        //messagesCollectionView.messageCellDelegate = self
//        messageInputBar.delegate = self
//
//    }
//
//
//
//}
//
//extension ChatViewController: MessagesDataSource {
//    func currentSender() -> SenderType {
//        if let sender = selfSender {
//            return sender
//        }
//
//        fatalError("Self Sender is nil, email should be cached")
//    }
//
//    func numberOfSections(
//    in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//
//  func messageForItem(
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//    return messages[indexPath.section]
//  }
//
//  func messageTopLabelHeight(
//    for message: MessageType,
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//    return 12
//  }
//
//  func messageTopLabelAttributedText(
//    for message: MessageType,
//    at indexPath: IndexPath) -> NSAttributedString? {
//
//    return NSAttributedString(
//      string: message.sender.displayName,
//      attributes: [.font: UIFont.systemFont(ofSize: 12)])
//  }
//}
//

//
//extension ChatViewController: MessagesDisplayDelegate {
//  func configureAvatarView(
//    _ avatarView: AvatarView,
//    for message: MessageType,
//    at indexPath: IndexPath,
//    in messagesCollectionView: MessagesCollectionView) {
//
////    let message = messages[indexPath.section]
////    let color = message.member.color
////    avatarView.backgroundColor = color
//    //TO DO - set image need
//  }
//}
//
//extension ChatViewController: InputBarAccessoryViewDelegate {
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
//            let selfSender = self.selfSender,
//            let messageId = createMessageId() else {
//                return
//        }
//
//        print("Sending: \(text)")
//
//        let mmessage = Message(sender: selfSender,
//                               messageId: messageId,
//                               sentDate: Date(),
//                               kind: .text(text))
//        messages.append(mmessage)
//        inputBar.inputTextView.text = ""
//        messagesCollectionView.reloadData()
//        messagesCollectionView.scrollToLastItem()
//
//        // Send Message
////        if isNewConversation {
////            // create convo in database
////            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: mmessage, completion: { [weak self]success in
////                if success {
////                    print("message sent")
////                    self?.isNewConversation = false
////                    let newConversationId = "conversation_\(mmessage.messageId)"
////                    self?.conversationId = newConversationId
////                    //self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
////                    self?.messageInputBar.inputTextView.text = nil
////                }
////                else {
////                    print("faield ot send")
////                }
////            })
////        }
////        else {
////            guard let conversationId = conversationId, let name = self.title else {
////                return
////            }
////
////            // append to existing conversation data
////            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: mmessage, completion: { [weak self] success in
////                if success {
////                    self?.messageInputBar.inputTextView.text = nil
////                    print("message sent")
////                }
////                else {
////                    print("failed to send")
////                }
////            })
////        }
//    }
//
//    private func createMessageId() -> String? {
//        // date, otherUesrEmail, senderEmail, randomInt
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: UserDefaultKey.userEmail) as? String else {
//            return nil
//        }
//
//        //let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
//
//        let dateString = Self.dateFormatter.string(from: Date())
//        let newIdentifier = "\(currentUserEmail)_\(dateString)"
//
//        print("created message id: \(newIdentifier)")
//
//        return newIdentifier
//    }
//}


class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, // <- background asyn type
           itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.messageInputBar.inputTextView.attributedText = self.makeContentView(image: image)
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                        }
                        
                    }
                }

               
            })
        }else {
            print("cannot find image")
        }
    }
    
    func makeContentView(image: UIImage) -> NSAttributedString {
        
        let fullString = NSMutableAttributedString()

        let image1Attachment = NSTextAttachment()

        image1Attachment.image = image
                
        let newImageWidth = (self.messageInputBar.inputTextView.bounds.size.width - 30)
        let scale = newImageWidth/image.size.width
        let newImageHeight = (image.size.height - 30) * scale
        image1Attachment.bounds = CGRect.init(x: 0, y: 300, width: newImageWidth, height: newImageHeight)
       
        image1Attachment.image = UIImage(cgImage: (image1Attachment.image?.cgImage!)!, scale: scale, orientation: .up)
        
        let imgString = NSAttributedString(attachment: image1Attachment)

        let fontSize = UIFont.systemFont(ofSize: 15)
        
        
     
        fullString.addAttribute(.font, value: fontSize, range: (self.messageInputBar.inputTextView.text as NSString).range(of: self.messageInputBar.inputTextView.text))
        fullString.append(imgString)
                
        return fullString

    }
    
    
    //var currentUser: User = Auth.auth().currentUser!
    var currentUser: Users = Users()
    
    private var docReference: DocumentReference? //현재 document
    var chatRoom: ChatRoom?
    var messages: [Message] = []
    var lastestMessage = Message(id: "", content: "", created: Date(), senderID: "", senderName: "")
    private var messageListener: ListenerRegistration?
    private var latestMessageObserver: NSObjectProtocol?
    
    //I'll send the profile of user 2 from previous class from which //I'm navigating to chat view. So make sure you have the following //three variables information when you are on this class.
//    var user2Name: String? = "jouureee"
//    var user2ImgUrl: String? = ""
//    var user2UID: String? = "jouureee@gmail.com"
    
    override func viewWillAppear(_ animated: Bool) {
        API.shared.getUserInfo(completion: { (response) in
            self.currentUser = response
            print("currentUser \(response)")
            self.messagesCollectionView.reloadData()
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.title = chatRoom?.chatRoomName
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        let image = UIImage(systemName: "camera")!
        let button = InputBarButtonItem(frame: CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height)))
        button.image = image
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)

        messageInputBar.leftStackView.alignment = .center //HERE
        messageInputBar.rightStackView.alignment = .center //HERE

        reloadInputViews()
        
        messageInputBar.inputTextView.placeholder = "메세지 입력"
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadMessage()
        
        latestMessageObserver = NotificationCenter.default.addObserver(forName: .didLatestMessageNotification, object: nil, queue:.main, using: { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    deinit {
        if let observer = latestMessageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc func didTapCameraButton(){
        print("didTapCameraButton")
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func loadMessage(){
        print("load Message")
        let document = Firestore.firestore().collection("Chats").document((chatRoom?.chatId)!)
        document.collection("thread")
            .order(by: "created", descending: false)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                } else {
                    //print("here")
                    self.docReference = document
                    self.messages.removeAll()
                    if let threads = threadQuery?.documents {
                        if(threads != []){ //빈 배열이 아닐때
                            for message in threads {
                                print(type(of: message.data()))
                                let DateFromFireStore: Dictionary<String, Any> = message.data()
                                
                                guard let content = DateFromFireStore["content"] as? String else {
                                    print("content type error")
                                    return
                                }
                                
                                guard let id = DateFromFireStore["id"] as? String else {
                                    print("id type error")
                                    return
                                    
                                }
                                
                                guard let created = DateFromFireStore["created"] as? Timestamp else {
                                    print("created type error")
                                    return
                                }
                                guard let senderName = DateFromFireStore["senderName"] as? String else {
                                    print("senderName type error")
                                    return
                                }
                                
                                guard let senderID = DateFromFireStore["senderID"] as? String else {
                                    print("senderID type error")
                                    return
                                }
                                
                                let msg = Message(id: id, content: content, created: Date(timeIntervalSince1970: TimeInterval(created.seconds)) , senderID: senderID, senderName: senderName)
                               
                                self.messages.append(msg) //TO DO
                                print("loadMessage : \(self.messages)")
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                            }
                        }
                       
                    }else {
                        print("This will run if threadQuery?.documents returns nil")
                    }
                }
            })
        
        }
    
    
    private func insertNewMessage(_ message: Message) {
    //add the message to the messages array and reload it
        messages.append(message)
        lastestMessage = message
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
      
        
        postPushNotification(messageContent: message.content)
       
    }
    
    
    //채팅 방 내 사람들에게 push noti 보내기
    private func postPushNotification(messageContent: String){
        var nickNameList = [String]()
        
        guard let postId = Int((chatRoom?.chatId)!) else {
            print("insertNewMessage can't find \(String(describing: chatRoom?.chatId))")
            return
        }
        
        ChatService.shared.getChatList(postId: postId, completionHandler: { (response) in
            for i in response {
                nickNameList.append(i.nickName)
                API.shared.pushNotification(nickname: i.nickName, message: messageContent)
            }
        })
        
        
    }
    
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID, // userNickName
            "senderName": message.senderName
        ]
        
    //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
//            print("save \(data)")
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
//        let message = Message(id: UUID().uuidString, content: text, created: Date(), senderID: currentUser.uid, senderName: currentUser.displayName!)
        //print("messageid \(UUID().uuidString)")
        let message = Message(id: UUID().uuidString, content: text, created: Date(), senderID: currentUser.email, senderName: currentUser.nickName)
        //print("messageid \(message)")
        
        insertNewMessage(message)
        save(message)
        
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
    
    //This method return the current sender ID and name
    func currentSender() -> SenderType {
        let chatUser: ChatUser?
        if let email = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail), let nickName = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail)  {
            chatUser = ChatUser(senderId: email, displayName: nickName)
            return chatUser!
        }
        return ChatUser(senderId: "", displayName: "")

//        return ChatUser(senderId: Auth.auth().currentUser!.uid, displayName: (Auth.auth().currentUser?.displayName)!)
        // return Sender(id: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
    }
    
    //This return the MessageType which we have defined to be text in Messages.swift
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
    
    
    
    // We want the default avatar size. This method handles the size of the avatar of user that'll be displayed with message
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    //Explore this delegate to see more functions that you can implement but for the purpose of this tutorial I've just implemented one function.
    
    
    //Background colors of the bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .green
    }
    
    func avatarPosition(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> AvatarPosition {
           .init(vertical: .messageBottom)
    }
    
    
    
    //THis function shows the avatar
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    
        //If it's current user show current user photo.

        API.shared.getUserInfo(completion: { (response) in
            self.currentUser = response
            print("currentUser \(response)")
            let urlString = Config.baseUrl + "/static/\(self.currentUser.profileImageUrl)"
           
            print(urlString)
            print(self.currentUser.nickName)
            if(message.sender.senderId == self.currentUser.email){
                print("it's me")
                SDWebImageManager.shared.loadImage(with: URL(string: urlString), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                    avatarView.image = image
                    avatarView.isHidden = self.isNextMessageSameSender(at: indexPath)
                }
            }else{
                SDWebImageManager.shared.loadImage(with: URL(string: ""), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                    avatarView.image = image
                    avatarView.isHidden = self.isNextMessageSameSender(at: indexPath)
                }
            }
           
        })
           
    

    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0) {
            return true
        }
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section + 1].sender.displayName
    }
    
    func isPreMessageSameSender(at indexPath: IndexPath) -> Bool {
        
        guard let index = indexPath.section - 1 as Int? else { return false }
        if(index < 0) {
            return false
        }
    
        return messages[indexPath.section].sender.displayName == messages[indexPath.section - 1].sender.displayName
    }
    
   
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        //print("corner : \(corner)")
       
        return .bubbleTail(corner, .curved)
    }

    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
           let name = message.sender.displayName
        if(isPreMessageSameSender(at: indexPath)){
            return NSAttributedString(string: "")
        }
        //print("messageTopLabelAttributedText \(name)")
           return NSAttributedString(string: name, attributes:
               [.font : UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black])
       }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_kr")
            formatter.dateFormat = "HH시 mm분"
   
        let dateString = formatter.string(from: message.sentDate)
        if(isNextMessageSameSender(at: indexPath)){
            return NSAttributedString(string: "")
        }
        //print("messageBottomLabelAttributedText \(dateString)")
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
       }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(isPreMessageSameSender(at: indexPath)) {
            return 2
        }
        return 15
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if(isNextMessageSameSender(at: indexPath)) {
            return 2
        }
        return 15
    }
    
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
//    }
    
    //display name
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
//    }
    
//    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 10
//    }
//
//    func heightForLocation(message: MessageType,
//        at indexPath: IndexPath,
//        with maxWidth: CGFloat,
//        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//        return 0
//      }

}

