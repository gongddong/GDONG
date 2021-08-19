//
//  NickNameViewController.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/28.
//

import UIKit

class NickNameViewController: UIViewController {

    @IBOutlet weak var nickNameTextfield: UITextField!
    var nickName = ""
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           let LocationVC = segue.destination as! LocationViewController
           LocationVC.nickName = nickNameTextfield.text!
       }
       

       @IBAction func nextButton(_ sender: Any) {
      
        
           if(nickNameTextfield.text == ""){
                let alertVC = UIAlertController(title: "닉네임 입력", message: "닉네임을 입력해주세요", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
           } else{
            //dp에 저장된 이름이 았으면
                 UserService.shared.checkNickName(nickName: nickNameTextfield.text!, completion: { (string) in
              
                     if(string == "true"){
                        self.performSegue(withIdentifier: "location", sender: nil)
                     }else if(string == "false"){
                        self.alertViewController(title: "중복 아이디 존재", message: "다른 아이디를 입력해주세요", completion: {(string) in })
                     }
                 })
            }
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
