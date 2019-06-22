//
//  PdetailViewController.swift
//  shareDiary
//
//  Created by 이유진 on 22/06/2019.
//  Copyright © 2019 이유진. All rights reserved.
//

import UIKit
import CoreData

class PdetailViewController: UIViewController {

    var detailDiary: NSManagedObject?
    
    @IBOutlet var dateText: UILabel!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var contentText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateText.text = detailDiary?.value(forKey: "date") as? String
        self.title = detailDiary?.value(forKey: "title") as? String
        titleText.text = detailDiary?.value(forKey: "title") as? String

        contentText.text = detailDiary?.value(forKey: "content") as? String
        
        // Do any additional setup after loading the view.
    }

    @IBAction func pressedShare(_ sender: UIBarButtonItem) {
        let alert=UIAlertController(title:"사람들과 공유하시겠습니까?", message: "",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "공유하기", style: .default, handler: { action in
            let urlString: String = "http://condi.swu.ac.kr/student/T12/insertDiary.php"
            guard let requestURL = URL(string: urlString) else {
                return
                
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            let restString: String = "name=" + appDelegate.userID! + "&title=" + self.titleText.text! + "&content=" + self.contentText.text! + "&date=" + self.dateText.text!
            request.httpBody = restString.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else { print("Error: calling POST")
                    return }
                guard let receivedData = responseData else { print("Error: not receiving Data")
                    return }
                if let utf8Data = String(data: receivedData, encoding: .utf8) { DispatchQueue.main.async { // for Main Thread Checker
                    print(utf8Data) // php에서 출력한 echo data가 debug 창에 표시됨
                    }
                }
            }
            task.resume()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
}
