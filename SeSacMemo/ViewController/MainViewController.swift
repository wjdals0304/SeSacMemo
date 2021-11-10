//
//  MainViewController.swift
//  SeSacMemo
//
//  Created by 김정민 on 2021/11/09.
//

import UIKit

class MainViewController: UIViewController {

    
    @IBOutlet var memoCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memoCountLabel.text = "test"
    }
    

}



extension MainViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
    }
    
    
    
    
    
}
