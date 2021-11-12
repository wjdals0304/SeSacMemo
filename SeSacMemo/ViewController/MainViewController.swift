//
//  MainViewController.swift
//  SeSacMemo
//
//  Created by 김정민 on 2021/11/09.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    

    let sectionTitles:[String] = ["고정된 메모","메모"]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var memoButton: UIButton!
    
    var filteredMemo: Results<UserMemo>!
    
    let localRealm = try! Realm()
    var tasks: Results<UserMemo>!
    
    var fixedMemoCount : Int = 0
    var unFixedMemoCount : Int = 0
    var totalMemoCount : Int = 0

    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.memoButton.setTitle("", for: .normal)
        self.memoButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        self.setupSearchController()
        tasks = localRealm.objects(UserMemo.self).sorted(byKeyPath: "writeDate", ascending: false)

     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        // 메모 개수
        self.fixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == true").count
        self.unFixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == false").count
        
        self.totalMemoCount = fixedMemoCount + unFixedMemoCount
        self.navigationItem.title = "\(totalMemoCount)개의 메모"

    }
    
    @IBAction func AddMemoButton(_ sender: UIButton) {
        
        let sb = UIStoryboard(name: "UpdateMemo", bundle: nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "UpdateMemoViewController") as! UpdateMemoViewController
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav,animated: true , completion: nil)
    }
    
    func setupSearchController() {
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.fixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == true").count
        self.unFixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == false").count
        
        self.totalMemoCount = fixedMemoCount + unFixedMemoCount
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "\(totalMemoCount)"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
    }
}



extension MainViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "UpdateMemo", bundle: nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "UpdateMemoViewController") as! UpdateMemoViewController
        
        vc.memoData = self.isFiltering ? filteredMemo[indexPath.row] : tasks[indexPath.row]

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
    
        self.present(nav,animated: true , completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier , for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        
        let row = tasks[indexPath.row]
        
        if self.isFiltering {
            
            let filterRow = filteredMemo[indexPath.row]
            cell.titleLabel.text  = filterRow.title
            cell.detailLabel.text =  filterRow.content
                                    
        } else {
            
            if indexPath.section == 0 {

                cell.titleLabel.text = row.fix ? row.title : nil
                cell.detailLabel.text = row.fix ? row.content : nil
                
            } else if row.fix == false {
                
                cell.titleLabel.text = row.title
                cell.detailLabel.text = row.content
            }
        }
        
        return cell

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.isFiltering == true {
            return 1
        } else {
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        self.fixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == true").count
        self.unFixedMemoCount = localRealm.objects(UserMemo.self).filter("fix == false").count
        

        if self.isFiltering == true {
            return filteredMemo.count
        } else {
            return section == 0 ? fixedMemoCount : unFixedMemoCount
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.isFiltering ? "\(filteredMemo.count)개" : sectionTitles[section].description
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete {
                
                let row = tasks[indexPath.row]

                try! localRealm.write {
                    localRealm.delete(row)
                }
                
                tableView.reloadData()
            }
        }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = self.tasks[indexPath.row]
    
        let memo = localRealm.objects(UserMemo.self).filter( "_id = %@",row._id).first
        
        let pinUI = UIContextualAction(style: .normal, title: "") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            if row.fix == true {
                                
                try! self.localRealm.write{
                    memo?.fix = false
                }
                
            } else {
                try! self.localRealm.write{
                    memo?.fix = true
                }
            }
            success(true)
        }
        
        if row.fix == true {
            pinUI.image = UIImage(systemName: "pin.slash.fill")
        } else {
            pinUI.image = UIImage(systemName: "pin.fill")
        }
        
        // pin 설정시 바로 적용이 안되는 문제가 있음
        tableView.reloadData()
        return UISwipeActionsConfiguration(actions: [pinUI])
    }
    
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        self.filteredMemo = self.localRealm.objects(UserMemo.self).filter("title CONTAINS %@" ,text)
        self.tableView.reloadData()
    }
}
