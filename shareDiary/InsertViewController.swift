//
//  InsertViewController.swift
//  shareDiary
//
//  Created by 이유진 on 22/06/2019.
//  Copyright © 2019 이유진. All rights reserved.
//

import UIKit
import CoreData

class InsertViewController: UIViewController {


    @IBOutlet var textdate: UITextField!
    @IBOutlet weak var texttitle: UITextField!
    @IBOutlet var textdiary: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myDate = formatter.string(from: Date())
        
        textdate.text = myDate
        
        // Do any additional setup after loading the view.
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Diary", in: context)
        
        let object = NSManagedObject(entity: entity!, insertInto: context)
        object.setValue(texttitle.text, forKey: "title")
        object.setValue(textdiary.text, forKey: "content")
        object.setValue(textdate.text, forKey: "date")
        
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        // 현재의 View를 없애고 이전 화면으로 복귀
        self.navigationController?.popViewController(animated: true)
    }

}
