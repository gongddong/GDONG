//
//  LoginViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/07.
//

import UIKit
import AuthenticationServices

import KakaoSDKAuth
import KakaoSDKUser
import KakaoOpenSDK
import GoogleSignIn
import Alamofire

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, GIDSignInDelegate {
    let viewModel = AuthenticationViewModel()
    var user: [Users] = []
 
    private var loginObserver: NSObjectProtocol?
    
    @IBOutlet weak var loginLabelText: UILabel!
    //temp button
//    private let loginButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("login", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.backgroundColor = .systemBlue
//        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
//        return button
//    }()

    //for apple login button view
    private var appleLoginButtonView: UIStackView = {
        let appleLoginButtonView = UIStackView()
        appleLoginButtonView.backgroundColor = .systemGray
        return appleLoginButtonView
    }()
    
    //apple login button
    private let appleLoginButton:ASAuthorizationAppleIDButton = {
        let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonClick), for: .touchUpInside)
        return appleLoginButton
    }()
    
    private let kakaoTalkLoginButton:KOLoginButton = {
        let button = KOLoginButton()
        button.addTarget(self, action: #selector(onKakaoLoginByAppTouched), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .standard
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        GIDSignIn.sharedInstance()?.presentingViewController = self // 로그인화면 불러오기
        GIDSignIn.sharedInstance().restorePreviousSignIn() // 자동 로그인
        GIDSignIn.sharedInstance()?.delegate = self
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue:.main, using: { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(googleLoginButton)
        appleLoginButtonView.addArrangedSubview(appleLoginButton)
        view.addSubview(appleLoginButtonView)
        view.addSubview(kakaoTalkLoginButton)
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false


        googleLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        googleLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        kakaoTalkLoginButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoTalkLoginButton.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 30).isActive = true
        
        kakaoTalkLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        kakaoTalkLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        kakaoTalkLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        appleLoginButtonView.translatesAutoresizingMaskIntoConstraints = false
        appleLoginButtonView.topAnchor.constraint(equalTo: kakaoTalkLoginButton.bottomAnchor, constant: 20).isActive = true
        
        appleLoginButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        appleLoginButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        appleLoginButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        appleLoginButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
//        googleLoginButton.frame = CGRect(x: 70, y: 300, width: 250, height: 40)
//        kakaoTalkLoginButton.frame = CGRect(x: 70, y: googleLoginButton.bottom + 20, width: 250, height: 40)

//        appleLoginButtonView.frame = CGRect(x: 70, y: kakaoTalkLoginButton.bottom + 20, width: 250, height: 40)
        
//        loginButton.frame = CGRect(x: 70, y: appleLoginButtonView.bottom + 20, width: 250, height: 40)
        
        appleLoginButton.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        //view.addSubview(loginButton)
    }
    
    //Apple Login
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case  let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            
            guard let identifyToken = appleIDCredential.identityToken else { return }
            guard let authoredCode = appleIDCredential.authorizationCode else { return }
            guard let fullName = appleIDCredential.fullName else { return }
            guard let email = appleIDCredential.email else { return }
            guard let tokeStr = String(data: identifyToken, encoding: .utf8) else { return }
            guard let codeStr = String(data: authoredCode, encoding: .utf8) else { return }
            
            print("Apple login")
            print("identifyToken : \(tokeStr)")
            print("authoredCode : \(codeStr)")
            print("User ID : \(userIdentifier)")
            print("User Email : \(email)")
            print("User Name : \(fullName)")
            print("authorizationController")
            UserDefaults.standard.setValue(userIdentifier, forKey: UserDefaultKey.appleIdentifier)
            LoginService.shared.oAuth(from: "apple", access_token: tokeStr, name: "\(fullName)")
//            self.autoLogin(UN: fullName.givenName! + fullName.familyName!, UE: email, FROM: "apple")

        default:
            break;
        }
        
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        // Handle error.
    }
    
    @objc func appleLoginButtonClick(){
        //apple id 기반으로 사용자 인증 요청
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        print("appleLoginButtonClick")
    }
    

    //google login
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if(error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("the user has not signed in before or they have since signed out ")
            }else {
                print("error : \(error.localizedDescription)")
            }
            return
        }
        // 사용자 정보 가져오기
            if let userName = user.profile.name,
//               let userEmail = user.profile.email,
//               let idToken = user.authentication.idToken,
               let accessToken = user.authentication.accessToken
                //let refreshToken = user.authentication.refreshToken
        { //send to server
                
                LoginService.shared.oAuth(from: "google", access_token: accessToken, name: userName)
                
            } else {
                print("Error : User Data Not Found")
            }

    }
    
    // 구글 로그인 연동 해제했을때 불러오는 메소드
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Disconnect")
    }
    
    @objc func didTapLoginButton(){
        self.MoveToAdditionalInfo()
    }
    
    
   
    //kakao login
    @objc func onKakaoLoginByAppTouched(_ sender: Any) {
        if(UserApi.isKakaoTalkLoginAvailable()){ // 이용가능하다면
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("loginWithKakaoAccount() success.")

                        //do something
                        let token = oauthToken
                        //print("kakao login \(token)")
                        guard let accessToken = token?.accessToken else {
                            return
                        }

                        //print("login access token \(accessToken)")
                        self.setUserInfo(accessToken: accessToken)
                    }
                }
        }
    }
    
    func setUserInfo(accessToken: String){
        UserApi.shared.me(){(user, error) in
            if let error = error {
                print(error)
            }else{
                print("me() success")
                _ = user
                print("kakao login")
                guard let userName = user?.kakaoAccount?.profile?.nickname else { return }
                LoginService.shared.oAuth(from: "kakao", access_token: accessToken, name: userName)

                
            }
        }
       
    }
    
    public func alertController(completion: @escaping ((String) -> Void)){
       let AlertVC = UIAlertController(title: "네트워크 오류", message: "네트워크 연결이 약해 앱을 종료합니다. 잠시 후 다시 이용헤주세요.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            completion("OK")
         })
        
        AlertVC.addAction(OKAction)
        
        self.present(AlertVC, animated: true, completion: nil)
    }
    

    func MoveToTabbar(){
        let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbar") as! UITabBarController

        UIApplication.shared.windows.first?.rootViewController = tabBarViewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func MoveToAdditionalInfo(){
       
        let nickVC = UIStoryboard.init(name: "AdditionalInfo", bundle: nil).instantiateViewController(withIdentifier: "nickName")
        
        let additionalNavVC = UINavigationController(rootViewController: nickVC)
       
        UIApplication.shared.windows.first?.rootViewController = additionalNavVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}


