//
//  LoginService.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/08/19.
//

import Foundation
import Alamofire

class LoginService {
    static var shared = LoginService()
    
    
    func oAuth(from: String, access_token: String, name: String) {
        
//        guard let authorEmail = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail) else { return }
//        guard let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken) else { return }
        
        guard let deviceToken: String = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken) else { return }
        
        let params: Parameters = [
                "access_token": access_token,
                "name": name,
                "device_token" : deviceToken
            ]
       

        AF.request(Config.baseUrl + "/auth/signin/\(from)", method: .get, parameters: params, encoding: URLEncoding(destination: .queryString)).validate().responseJSON {
            
            (response) in
            print("[API] /auth/signin/\(from) 로그인 하기")
            if let httpResponse = response.response, let fields = httpResponse.allHeaderFields as? [String: String]{
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: (response.response?.url)!)
                HTTPCookieStorage.shared.setCookies(cookies, for: response.response?.url, mainDocumentURL: nil)
                
                if let session = cookies.filter({$0.name == "token"}).first {
                    
                    UserDefaults.standard.setValue(session.value, forKey: UserDefaultKey.jwtToken)
                    print("============ Cookie vlaue =========== : \(session.value)")
                    
                }
                
            }
            
            switch response.result {
            
            case .success(let obj):
                    do{
                        let responses = obj as! NSDictionary
                        
                        guard let user = responses["user"] as? Dictionary<String, Any> else { return }
                        
                        let isNew = responses["isNew"]
                        
                        let dataJSON = try JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)

                        let UserData = try JSONDecoder().decode(Users.self, from: dataJSON)
                        print(UserData)

                        UserDefaults.standard.set(UserData.email, forKey: UserDefaultKey.userEmail)
                        UserDefaults.standard.set(UserData.isSeller, forKey: UserDefaultKey.isSeller)
                        UserDefaults.standard.set(access_token, forKey: UserDefaultKey.accessToken)
                        UserDefaults.standard.set(isNew, forKey: UserDefaultKey.isNewUser)
                        UserDefaults.standard.set(UserData.name, forKey: UserDefaultKey.userName)
                        UserDefaults.standard.set(UserData.authProvider, forKey: UserDefaultKey.authProvider)
                        UserDefaults.standard.set(UserData.nickName, forKey: UserDefaultKey.userNickName)
                        
                        self.autoLogin()
                    }
                    catch let DecodingError.dataCorrupted(context) {
                            print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
            case .failure(let e):
                print("connected failed")
                print(e.localizedDescription)
                
        }
            
    }

    //로그인 옵저버
    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        
    }
    
    
    func checkAutoLogin() -> Bool {
        guard let from = UserDefaults.standard.string(forKey: UserDefaultKey.authProvider) , let accseeToken = UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) , let name = UserDefaults.standard.string(forKey: UserDefaultKey.userName) , let jwt = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken) else {
            print("저장된 정보가 없어 login view로 이동")
            return false
        }
        
        if from != "", accseeToken != "", name != "", jwt != "" {
            oAuth(from: from, access_token: accseeToken, name: name)
            return true
        }
        
        return false
    }
    
    
    func autoLogin(){
        print("autoLogin method call")
        //if user is new --> 1
        print(UserDefaults.standard.integer(forKey: UserDefaultKey.isNewUser))
        if UserDefaults.standard.integer(forKey: UserDefaultKey.isNewUser) == 1 {
            //MoveToAdditionalInfo
            let nickVC = UIStoryboard.init(name: "AdditionalInfo", bundle: nil).instantiateViewController(withIdentifier: "nickName")
            
            let additionalNavVC = UINavigationController(rootViewController: nickVC)
            UIApplication.shared.windows.first?.rootViewController = additionalNavVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        }else {
            let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbar") as! UITabBarController

            UIApplication.shared.windows.first?.rootViewController = tabBarViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }

    }
}
