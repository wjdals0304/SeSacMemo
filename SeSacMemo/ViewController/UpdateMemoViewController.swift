//
//  UpdateMemoViewController.swift
//  SeSacMemo
//
//  Created by 김정민 on 2021/11/10.
//

import UIKit
import RealmSwift

class UpdateMemoViewController: UIViewController {


    @IBOutlet var textView: UITextView!
    
    let localRealm = try! Realm()
    var titleText : String = ""
    var contentText : String = ""
    var selectedBool : Bool = false
    
    var tasks: Results<UserMemo>!

    var memoData: UserMemo?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonClicked))
        
       navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(saveButtonClicked))
        
        if memoData != nil {
            self.textView.text = "\(memoData!.title) \n \(memoData!.content)"
            self.selectedBool = true
        }
        
        
        

    }
    
    
     @objc func closeButtonClicked() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonClicked() {
        
        let textArray = textView.text?.components(separatedBy: CharacterSet.newlines) ?? []
        
        self.titleText = textArray[0]
        
        for i in 1..<textArray.count {
            self.contentText += textArray[i]
        }
        

        // 존재하는 데이터
        if self.selectedBool == true {
            
            let memo = localRealm.objects(UserMemo.self).filter( "_id = %@",memoData!._id).first
            
            try! localRealm.write {
            
                memo?.title = titleText
                memo?.content = contentText
                memo?.writeDate = Date()
            }
            
        } else {
            let task = UserMemo(title: titleText, content: contentText, writeDate: Date())

            
            try! localRealm.write {
                localRealm.add(task)
            }
        }
       

        
        self.dismiss(animated: true, completion: nil)
    }
    
}


