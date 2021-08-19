//
//  EditProfileViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/06/22.
//

import UIKit
import CoreLocation
import PhotosUI
import SDWebImage

class EditProfileViewController: UIViewController, CLLocationManagerDelegate {
   
    
    
    var locationManager: CLLocationManager!
    
    
    var userInfo = Users()
    @IBOutlet weak var imageEditButton: UIImageView!
    @IBOutlet weak var userImage: SDAnimatedImageView!
    
    
//    var nameValue: String = ""
//    var nowLatitude: Double = -1.0
//    var nowLongitude: Double = -1.0
    
    @IBOutlet var tableView: UITableView!
    
  
    //update user info from server
    @IBAction func doneButton(_ sender: Any) {
        guard let image: Data =  userImage.image?.jpeg(.lowest) else {
            return
        }
        guard let nickname = userInfo.nickName as String? else { return }
        guard let nowLongitude = userInfo.location.coordinates[0] as Double? else {
            return
        }
        guard let nowLatitude = userInfo.location.coordinates[1] as Double? else {
            return
        }
        print(image)
        print(nickname)
        print(nowLongitude)
        print(nowLatitude)
       
        if(!image.isEmpty){ // 유저 이미지도 같이 업데이트 되었다면
            //post user setting image
            print("image도 같이 업데이트")
            UserService.shared.updateWithUserImage(userImage: image, change_img: "true", nickName: nickname, longitude: nowLongitude, latitude: nowLatitude, completion: { (users) in
               if(users.email != ""){
                   self.alertDone(title: "수정 완료", message: "프로필이 수정 되었습니다",  completionHandler: { response in
                        if(response == "OK"){
                            self.navigationController?.popViewController(animated: true)
                        }
                   })
               }
           })
            
        } else {  // 이름과 위치 정보만 업데이트시
            print("image x이 업데이트")
            UserService.shared.updateUser(nickName: nickname, longitude: nowLongitude, latitude: nowLatitude, completion: { (users) in
                if(users.email != ""){
                    self.alertDone(title: "수정 완료", message: "프로필이 수정 되었습니다",  completionHandler: { response in
                        if(response == "OK"){
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            })
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private let sec = ["사용자 정보", "연동 계정"]
    
    
    func checktAccount(){
        let connectedAccountVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "connectAccount")
            connectedAccountVC.modalPresentationStyle = .fullScreen
            self.present(connectedAccountVC, animated: true, completion: nil)
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editImage))
        imageEditButton.addGestureRecognizer(tapGestureRecognizer)
        imageEditButton.isUserInteractionEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InputTableViewCell.nib(), forCellReuseIdentifier: InputTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        infoLoad()


    }
    
    func infoLoad(){
        self.userImage.circle()
        UserService.shared.getUserInfo(completion: { (user) in
            self.userInfo = user
            if(user.profileImageUrl != ""){
                print("db에 있는 유저 이미지 불러오기")
                print(user.profileImageUrl)
                let urlString = Config.baseUrl + "/static/\(user.profileImageUrl)"
                    
                    if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                        self.userImage.sd_setImage(with: myURL, completed: nil)
                        self.userImage.contentMode = .scaleAspectFill
                }
            }
        })
    }
    

    
    @objc func editImage(){
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func alertDone(title: String, message: String, completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in  completionHandler("OK")})
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    func locationSetting(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }

    
    func getLocation(cellField: UITextField){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let coor = locationManager.location?.coordinate
        guard let latitude = coor?.latitude, let longitude = coor?.longitude else {
            print("can not load location")
            return
        }

        let findLocation = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")

        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(place, error) in
            if let address: [CLPlacemark] = place {
                if let name: String = address.last?.name{
                    cellField.text = name
                    self.userInfo.location.coordinates[0] = longitude
                    self.userInfo.location.coordinates[1] = latitude
                }
            }
        })
    }

    
    func alertEditLocation(cellField: UITextField){
        let alertVC = UIAlertController(title:"위치 정보 수정", message: nil, preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "확인", style: .default, handler: {
            (okAction) in
            //get Location func called
            self.getLocation(cellField: cellField)
        })
        let cancelAction =  UIAlertAction(title: "취소", style: .cancel)
        alertVC.addAction(OkAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    private var nameTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
        
    
    func alertEditName(cellField: UITextField){
        let alertVC = UIAlertController(title: "회원 정보 수정", message: nil, preferredStyle: .alert)

        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.nameTextField = textField
            self.nameTextField.placeholder = "새로 수정할 닉네임을 입력해주세요"
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        
        let createAction = UIAlertAction(title: "create", style: .default, handler: { (action) -> Void in
            if let userInput = self.nameTextField.text  {
        
                label.isHidden = true
                label.textColor = .red
                label.font = label.font.withSize(12)
                label.textAlignment = .center
                label.text = ""
                alertVC.view.addSubview(label)

                if userInput == "" {
                    label.text = "이름을 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }else{
                    UserService.shared.checkNickName(nickName: userInput, completion: { (string) in
                        if(string == "false"){
                            label.text = "이미 같은 이름을 가진 사용자가 있습니다"
                            label.isHidden = false
                            self.present(alertVC, animated: true, completion: nil)
                        }else{
                            cellField.text = userInput
                            self.userInfo.nickName = userInput
                        }
                        
                    })
                }
            }

        })
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertVC.addAction(createAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, // <- background asyn type
           itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.userImage.image = image
                        self.userImage.contentMode = .scaleAspectFill
                    }
                }

               
            })
        }else {
            print("cannot find image")
        }
    }
    
    
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource,InputTableViewCellDelegate {
    
    func change(cell: InputTableViewCell) {
        print("get \(cell.indexPath)")
        if(cell.indexPath[1] == 0){
            alertEditName(cellField: cell.textfield)
            
        }else if(cell.indexPath[1] == 1){
            alertEditLocation(cellField: cell.textfield)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sec.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else if (section == 1){
            return 1
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if(indexPath.section == 0 && indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: InputTableViewCell.identifier)as! InputTableViewCell
            cell.label.text = "아이디 :"
            if let userNickName = UserDefaults.standard.string(forKey: UserDefaultKey.userNickName) {
                cell.textfield.text = userNickName
            }
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }else if(indexPath.section == 0 && indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: InputTableViewCell.identifier) as! InputTableViewCell
            cell.label.text = "위치 :"
            cell.setLocation()
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }else if(indexPath.section == 1){
            
            defaultCell.textLabel?.text = "연동 계정 확인"
            defaultCell.accessoryType = .disclosureIndicator
            return defaultCell
        }
        
        return defaultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){ // 연동 정보 뷰로 이동
            guard let connectedVC = self.storyboard?.instantiateViewController(identifier: "connectAccount") as? ConnectedViewController else {
                return
            }
            connectedVC.modalPresentationStyle = .fullScreen
            self.present(connectedVC, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
