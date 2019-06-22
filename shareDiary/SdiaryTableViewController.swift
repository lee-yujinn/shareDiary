//
//  SdiaryTableViewController.swift
//  shareDiary
//
//  Created by 이유진 on 22/06/2019.
//  Copyright © 2019 이유진. All rights reserved.
//

import UIKit

class SdiaryTableViewController: UITableViewController, UISearchResultsUpdating {
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    var searchData:[String] = []

    var fetchedArray: [ShareDiary] = Array()
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (searchData as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchData.removeAll()
        fetchedArray = []     // 배열을 초기화하고 서버에서 자료를 다시 가져옴
        self.downloadDataFromServer()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetailView" {
            if let destination = segue.destination as? SdetailViewController {
                if let selectedIndex = self.tableView.indexPathsForSelectedRows?.first?.row {
                    let data = fetchedArray[selectedIndex]
                    destination.selectedData = data
                }
            }
        }
    }
    
    
    func downloadDataFromServer() -> Void {
        let urlString: String = "http://condi.swu.ac.kr/student/T12/fetchDiary.php"
        guard let requestURL = URL(string: urlString) else { return }
        let request = URLRequest(url: requestURL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else { print("Error: calling POST"); return; }
            guard let receivedData = responseData else {
                print("Error: not receiving Data"); return;
            }
            let response = response as! HTTPURLResponse
            
            if !(200...299 ~= response.statusCode) { print("HTTP response Error!"); return }
            do {
                if let jsonData = try JSONSerialization.jsonObject (with: receivedData,
                                                                    options:.allowFragments) as? [[String: Any]] {
                    for i in 0...jsonData.count-1 {
                        let newData: ShareDiary = ShareDiary()
                        var jsonElement = jsonData[i]
                        newData.name = jsonElement["name"] as! String
                        newData.title = jsonElement["title"] as! String
                        newData.date = jsonElement["date"] as! String
                        newData.content = jsonElement["content"] as! String
                        self.searchData.append(jsonElement["title"] as! String)
                        self.fetchedArray.append(newData)
                    }
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            } catch { print("Error: Catch") }
        }
        task.resume()
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return fetchedArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Sdiary Cell", for: indexPath)
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            
            return cell
        }
        else{
        // Configure the cell...
            let item = fetchedArray[indexPath.row]
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.name
            
            return cell
        }
    }

}
