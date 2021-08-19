//
//  DataManger.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/21.
//

import Foundation
import Alamofire

class UserService {
    static var shared = UserService()
    
    var email: String
    var jwtToken: String
    
    init(){
        email = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail)!
        jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
    }
    
    //user info
    func getUserInfo(completion: @escaping ((Users) -> Void) ){
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        AF.request(Config.baseUrl + "/user/info", method: .get, parameters: nil, headers: headers).validate(statusCode: 200...500 ).responseJSON {
            (response) in
            print("[UserService] /user/info 유저 정보 불러오기")
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
                    do {
                        let responses = obj as! NSDictionary
                        guard let user = responses["user"] as? Dictionary<String, Any> else { return }
                        
                        let dataJSON = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)

                        let UserData = try JSONDecoder().decode(Users.self, from: dataJSON)
                        completion(UserData)
                    } catch {
                        print("error: ", error)
                    }
                    
                    
                case .failure(let e):
                    print(e.errorDescription as Any)
            }
        }
    }
    
    
    
    //no such user
    func userQuit(){
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        AF.request(Config.baseUrl + "/user/quit", method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            print("user quit(회원 탈퇴) : \(response.result)")
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
            case .success(let code):
                print(code)
                break
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    
    func updateUser(nickName: String, longitude: Double, latitude: Double, completion: @escaping ((Users) -> (Void))){

        let params: Parameters = [
            "nickname" : nickName,
            "longitude": longitude,
            "latitude": latitude
        ]
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)",
            "Content-type": "multipart/form-data"
        ]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if let temp = value as? Double {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }
                
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }

            }
           
            
        }, to: Config.baseUrl + "/user/update", usingThreshold: UInt64.init(), method: .post, headers: headers).validate().responseJSON { (response) in
            
            print("[UserService] /user/update 유저 정보 업데이트")
            
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
                do {
                    let responses = obj as! NSDictionary
                    guard let user = responses["user"] as? Dictionary<String, Any> else { return }

                    let dataJSON = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)

                    let UserData = try JSONDecoder().decode(Users.self, from: dataJSON)
                    completion(UserData)
                } catch {
                    print("error: ", error)
                }

            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    func updateWithUserImage(userImage: Data, change_img: String, nickName: String, longitude: Double, latitude: Double, completion: @escaping ((Users) -> (Void))) {
        let url = Config.baseUrl + "/user/update"
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        let params: Parameters = [
            "nickname" : nickName,
            "longitude": longitude,
            "latitude": latitude,
            "change_img" : change_img
        ]
        
        
        AF.upload(multipartFormData: { multipartFormData in

            var fileName = "\(userImage).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            multipartFormData.append(userImage, withName: "images", fileName: fileName, mimeType: "image/jpg")
            
            for (key, value) in params {
                if let temp = value as? Double {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }
                
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }

            }
    
        }, to: url, usingThreshold: UInt64.init(), method: .post, headers: headers).validate().responseJSON { (response) in
            print("[UserService] /user/update 유저 이미지 업데이트")
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
                do {
                    let responses = obj as! NSDictionary
                    guard let user = responses["user"] as? Dictionary<String, Any> else { return }

                    let dataJSON = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)

                    let UserData = try JSONDecoder().decode(Users.self, from: dataJSON)
                    completion(UserData)
                } catch {
                    print("error: ", error)
                }

            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    func checkNickName(nickName: String, completion: @escaping ((String) -> Void)) {
        
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        let url = Config.baseUrl + "/user/checknickname"
     
        let parameters: [String: Any] = ["nickname": nickName]
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).validate().responseJSON { (response) in
            print("[UserService] \(nickName) 중복 확인: \(response.result)")
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
                let responses = obj as! NSDictionary
                let bool = responses["result"] as! String
                print(bool)
                completion(bool)
                break
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    func userFollow(nickName: String){
        let parameters: [String: Any] = ["nickname": nickName]
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        AF.request(Config.baseUrl + "/user/follow", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            print("[UserService] user 팔로우: \(response.result)")
            switch response.result {
            case .success(let code):
                print(code)
                break
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
    }
    
    func userUnfollow(nickName: String){
        let parameters: [String: Any] = ["nickname": nickName]
        
        let headers: HTTPHeaders = [
            "Set-Cookie" : "email=\(email); token=\(jwtToken)"
        ]
        
        AF.request(Config.baseUrl + "/user/unfollow", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            print("[UserService] user 언팔로우: \(response.result)")
            switch response.result {
            case .success(let code):
                print(code)
                break
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
    }
    
    
    
    static func setCookies(cookies: HTTPCookie){
        Alamofire.Session.default.session.configuration.httpCookieStorage?.setCookie(cookies)
    }
    
    func findAddress(keyword: String, completion: @escaping ((JusoResponse) -> Void)){
        let url = "https://www.juso.go.kr/addrlink/addrLinkApi.do"
        
        let parameters: [String: Any] = ["confmKey": "devU01TX0FVVEgyMDIxMDUzMDAxMDMzNzExMTIyMjE=",
                                                    "currentPage": "1",
                                                    "countPerPage":"10",
                                                    "keyword": keyword,
                                                    "resultType": "json"]
    
        AF.request(url, method: .get, parameters: parameters).responseJSON{ [weak self] (response) in
            guard let self = self else { return }
            if let value = response.value {
                if let jusoResponse: JusoResponse = self.toJson(object: value) {
                    completion(jusoResponse)
                    }else {
                        print("serialize error")
                    }
            }
        }
    }
        
    private func toJson<T: Decodable>(object: Any) -> T? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: object) {
                    let decoder = JSONDecoder()
                    
                    
                    if let result = try? decoder.decode(T.self, from: jsonData) {
                        return result
                    } else {
                        return nil
                    }
                } else {
                  return nil
                }

    }

           
}



