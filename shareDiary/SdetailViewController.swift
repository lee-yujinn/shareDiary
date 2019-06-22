//
//  SdetailViewController.swift
//  shareDiary
//
//  Created by 이유진 on 22/06/2019.
//  Copyright © 2019 이유진. All rights reserved.
//

import UIKit

class SdetailViewController: UIViewController {

    @IBOutlet var textTitle: UILabel!
    @IBOutlet var textDate: UILabel!
    @IBOutlet var textContent: UITextView!
    @IBOutlet var textName: UILabel!
    
    var selectedData: ShareDiary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        guard let diaryData = selectedData else { return }
        
        self.title = diaryData.title
        self.textTitle.text = diaryData.title
        self.textDate.text = diaryData.date
        self.textContent.text = diaryData.content
        self.textName.text = diaryData.name
    }


}
