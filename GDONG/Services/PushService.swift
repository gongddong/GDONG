//
//  PushService.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/08/19.
//

import Foundation
import Alamofire

class PushService {
    static var shared = PushService()
    
    var email: String
    var jwtToken: String
    
    init(){
        email = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail)!
        jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
    }
    
    func pushNotification(nickname: String, message: String){
        
        let parameters: [String: Any] = ["nickname": nickname, "message": message]
        var request = URLRequest(url: URL(string: Config.baseUrl + "/apn/push")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.setValue("email=\(email); token=\(jwtToken)", forHTTPHeaderField:  "Set-Cookie")
        
        
        let formDataString = (parameters.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        
        let formEncodedData = formDataString.data(using: .utf8)
       
        
        request.httpBody = formEncodedData
        AF.request(request).responseJSON { (response) in
            print(response)
            print("[UserService] /apn/push apn push 메세지 보내기")
            
            if let httpResponse = response.response, let fields = httpResponse.allHeaderFields as? [String: String]{
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: (response.response?.url)!)
                HTTPCookieStorage.shared.setCookies(cookies, for: response.response?.url, mainDocumentURL: nil)
                
                //서버로 부터 받아오는 쿠키 값이 undefined가 아니면 앱 상 jwtToken 값 업데이트 하기
                if let session = cookies.filter({$0.name == "token"}).first {
                    print("============ Cookie vlaue =========== : \(session.value)")
                    if(session.value != "undefined"){
                        print("////////// update cookie value ///////")
                        UserDefaults.standard.setValue(session.value, forKey: UserDefaultKey.jwtToken)
                    }
                }
            }
            switch response.result {
            case .success(let obj):
                print(obj)
                
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
    }
        
    
}
