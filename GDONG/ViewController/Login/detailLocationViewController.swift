//
//  detailLocationViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/29.
//

import UIKit
import Alamofire
import CoreLocation

class detailLocationViewController: UIViewController {

    var searchKeyword = ""
    var jusoResult: [JusoResults] = []
    var jusoLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextfield: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchTextfield.text = searchKeyword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchWithJuso()
      
        
    }
    
    func searchWithJuso(){
        if !searchKeyword.isEmpty {
            UserService.shared.findAddress(keyword: searchKeyword){ [weak self]
                (jusoResponse) in
                guard let self = self else { return }
                if(!jusoResponse.results.juso.isEmpty){
                    //print(jusoResponse.results.common)
                    for i in jusoResponse.results.juso {
                        self.jusoResult.append(JusoResults(common: jusoResponse.results.common, juso: [Juso(roadAddr: i.jibunAddr, jibunAddr: i.roadAddr)]))
                        print(self.jusoResult)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                }else {
                    print("검색 결과가 없습니다.")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }


        }
    }
    
//    func geoLocate(address: String) -> CLLocation {
//        var latitude: CLLocationDegrees = CLLocationDegrees()
//        var logitude: CLLocationDegrees = CLLocationDegrees()
//               let gc:CLGeocoder = CLGeocoder()
//               gc.geocodeAddressString(address) { (placemarks, error) in
//                   if ((placemarks?.count)! > 0){
//                       let p = placemarks![0]
//                    latitude = (p.location?.coordinate.latitude)!
//                    logitude = (p.location?.coordinate.longitude)!
//
//                    print("Lat: \(latitude) Lon: \(logitude)")
//                }
//
//           }
//        return CLLocation(latitude: latitude, longitude: logitude)
//    }
    
    
    func alertController(juso: String, completion: @escaping ((String) -> Void)){
        let alertVC = UIAlertController(title: "현재 위치 확인", message: "\(juso)를 현재 위치로 설정하시겠습니까?", preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { action in
           completion("OK")
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
       
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let locationVC = segue.destination as? LocationViewController {
            let index = tableView.indexPathForSelectedRow
            locationVC.getLocation = jusoResult[index!.row].juso[0].jibunAddr
            
            let gc:CLGeocoder = CLGeocoder()
            gc.geocodeAddressString(jusoResult[index!.row].juso[0].jibunAddr) { [self] (placemarks, error) in
                if ((placemarks?.count)! > 0){
                    let p = placemarks![0]
                    let latitude = (p.location?.coordinate.latitude)!
                    let logitude = (p.location?.coordinate.longitude)!
                jusoLocation = CLLocation(latitude: latitude, longitude: logitude)
                //locationVC.getCLLocation = jusoLocation
                locationVC.nowLocation = jusoLocation
             }

        }
            
//            jusoLocation = geoLocate(address: jusoResult[index!.row].juso[0].jibunAddr)
//            print("prepare geoLocate \(jusoLocation.coordinate.latitude)")
//            print("prepare geoLocate \(jusoLocation.coordinate.longitude)")
//            locationVC.getCLLocation = jusoLocation
        }
        
    }
        
}



extension detailLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jusoResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(JusoTableViewCell.nib(), forCellReuseIdentifier: JusoTableViewCell.identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: JusoTableViewCell.identifier) as! JusoTableViewCell

        cell.jibun.text = jusoResult[indexPath.row].juso[0].jibunAddr
        cell.doro.text = jusoResult[indexPath.row].juso[0].roadAddr

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let text = jusoResult[indexPath.row].juso[0].jibunAddr else { return }
        alertController(juso: text, completion: {
            ok in
            if(ok == "OK"){
                
                self.performSegue(withIdentifier: "goback", sender: nil)
                
            }
            })
        }
    
    
    
}
