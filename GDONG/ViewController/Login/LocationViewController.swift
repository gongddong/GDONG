//
//  LocationViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/28.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationTextfield: UITextField!
    
    var getLocation = ""
    var myLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var nowLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var nickName = ""
    
    @IBAction func findCurrentLocaButton(_ sender: Any) {
        
        self.nowLocation = self.myLocation
        
        print("now Location is \(nowLocation)")
        
        locationTextfield.text = currentLocation
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        guard let textField = locationTextfield.text else { return }
        if(textField == ""){
            self.showToast(message: "위치를 입력해주세요", font: UIFont.systemFont(ofSize: 10))
        } else{
            performSegue(withIdentifier: "search", sender: nil)
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        //post location
        print("nickname is \(nickName)")
        print(locationTextfield.text)
        
        print("현재 위치 ")
        let nowLatitude = nowLocation.coordinate.latitude
        let nowLongitude =  nowLocation.coordinate.longitude
        print(nowLatitude)
        print(nowLongitude)
        print("\(nickName)")
        if (nowLatitude != 0.0 && nowLongitude != 0.0){
            //post
            UserService.shared.updateUser(nickName: nickName, longitude: nowLongitude, latitude: nowLatitude, completion: { (users) in
                let userNickName = users.nickName
                //let userLocation = users.location.coordinates
                UserDefaults.standard.setValue(self.getLocation, forKey: UserDefaultKey.userLocation)
                UserDefaults.standard.setValue(userNickName, forKey: UserDefaultKey.userNickName)
            })
            
            let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbar") as! UITabBarController

            UIApplication.shared.windows.first?.rootViewController = tabBarViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }else {
            showAlertVC()
        }
    }
    
    
    
    func showAlertVC(){
        let alertVC = UIAlertController(title: "생성 실패", message: "위치 정보를 입력해주세요", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    var locationManager: CLLocationManager!
    var currentLocation = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! detailLocationViewController

        guard let textField = locationTextfield.text else { return }

        detailVC.searchKeyword = textField
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(nickName)
        print("now Location is \(nowLocation)")
        
        
        if(getLocation != ""){
            locationTextfield.text = getLocation
        }else{
            locationTextfield.text = ""
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //foreground 일때 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longitude = coor?.longitude
        
        myLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        
        geocoder.reverseGeocodeLocation(myLocation, preferredLocale: locale, completionHandler: {(place, error) in
            if let address: [CLPlacemark] = place {
                if let name: String = address.last?.name{
                    print(name)
                    self.currentLocation = name
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    


}
