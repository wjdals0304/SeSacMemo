//
//  UserMemo.swift
//  SeSacMemo
//
//  Created by 김정민 on 2021/11/10.
//

import Foundation
import RealmSwift

class UserMemo: Object {
    
    @Persisted var title: String
    @Persisted var content : String
    @Persisted var writeDate = Date()
    @Persisted var fix : Bool
    
    
    @Persisted(primaryKey: true) var _id : ObjectId
    
    convenience init(title: String, content: String, writeDate : Date) {
        
        self.init()
        
        self.title = title
        self.content = content
        self.writeDate = writeDate
        self.fix = false 
    
    }
    
    
}
