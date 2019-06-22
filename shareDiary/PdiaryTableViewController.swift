//
//  DiaryTableViewController.swift
//  sharing
//
//  Created by 이유진 on 21/06/2019.
//  Copyright © 2019 이유진. All rights reserved.
//

import UIKit
import CoreData

class PdiaryTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var diary: [NSManagedObject] = []
    var diarysear: [String] = []
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        self.tableView.reloadData()
        super.viewDidLoad()
        
        diarysear.removeAll()
        
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        let sortDescriptor = NSSortDescriptor (key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            diary = try context.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)") }
        self.tableView.reloadData()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
      
        // Reload the table
        self.tableView.reloadData()
        
       
        for i in 0...diary.count-1{
            diarysear.append(diary[i].value(forKey: "title") as! String)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        let sortDescriptor = NSSortDescriptor (key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            diary = try context.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)") }
        self.tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (diarysear as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetailView" {
            if let destination = segue.destination as? PdetailViewController {
                if let selectedIndex = self.tableView.indexPathsForSelectedRows?.first?.row {
                    let data = diary[selectedIndex]
                    destination.detailDiary = data
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func numberOfSections (in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int)->Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return diary.count
        }
    
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Diary Cell", for: indexPath) // Configure the cell...
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            
            return cell
        }
       
        else{
            
            let diarys = diary[indexPath.row]
        
            cell.textLabel?.text = diarys.value(forKey: "title") as? String
            cell.detailTextLabel?.text = diarys.value(forKey: "date") as? String
        
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Core Data 내의 해당 자료 삭제
            let context = getContext()
            context.delete(diary[indexPath.row])
            do {
                try context.save()
                print("deleted!")
            } catch let error as NSError {
                print("Could not delete \(error), \(error.userInfo)") }
            // 배열에서 해당 자료 삭제
            diary.remove(at: indexPath.row)
           
            // 테이블뷰 Cell 삭제
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
