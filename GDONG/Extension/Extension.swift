//
//  Extension.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/05/06.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var top: CGFloat {
        return self.frame.size.width
    }
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    
}

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
        
    func symbolForNSToolbar() -> UIImage? {
        guard let symbol = applyingSymbolConfiguration(.init(pointSize: 13)) else { return nil }
        
        let format = UIGraphicsImageRendererFormat()
        format.preferredRange = .standard
        
        return UIGraphicsImageRenderer(size: symbol.size, format: format).image { _ in symbol.draw(at: .zero) }.withRenderingMode(.alwaysTemplate)
    }
    
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

extension Date {
        public var year: Int {
            return Calendar.current.component(.year, from: self)
        }
        
        public var month: Int {
             return Calendar.current.component(.month, from: self)
        }
        
        public var day: Int {
             return Calendar.current.component(.day, from: self)
        }
        
        public var monthName: String {
            let nameFormatter = DateFormatter()
            nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
            return nameFormatter.string(from: self)
        }
}

extension UIImageView {
    func circle(){
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
}

extension UIButton {
    func circle(){
        self.layer.cornerRadius = 0.5
         * self.bounds.size.width
        self.clipsToBounds = true
    }
   
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}


extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
    static let didLatestMessageNotification = Notification.Name("didLatestMessageNotification")
}

class DateUtil {
    //date parsing
    static func parseDate(_ dateString: String) -> Date {
        let dates = DateFormatter()
        dates.locale = Locale(identifier: "ko_kr")
        dates.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        print("parseDate \(dateString)")
// 
//        print("format \(dates.date(from: dateString)!)")
        return dates.date(from: dateString)!
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"

        return formatter.string(from: date)
    }
    
    static func latestMessageformatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH : mm"

        return formatter.string(from: date)
    }
}


extension UIViewController{
    func alertViewController(title: String, message: String, completion: @escaping  (String) -> Void){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion("OK")
        })
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alertWithNoViewController(title: String, message: String, completion: @escaping  (String) -> Void){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion("OK")
        })
        let CANCELAction = UIAlertAction(title: "취소", style: .default, handler:  nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(CANCELAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}


