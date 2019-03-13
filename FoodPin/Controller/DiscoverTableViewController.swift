//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Makan Fofana on 3/9/19.
//  Copyright © 2019 MakanFofana. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    var restaurants: [CKRecord] = []
    var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Activity Spinner Styling
        spinner.style = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        //Definiing the Spinner layout constraints
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
                 spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        //Activating The Spinner
        spinner.startAnimating()
        
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Formatting the navigation view controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor(red: 233, green: 76, blue: 60), NSAttributedString.Key.font: customFont ]
        }
        
        fetchRecordsFromCloud()
    }
    
    
    //Fetching Data From ICloud Database using convenience API
    func fetchRecordsFromCloud(){
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        //Creating the quesry option using operational API
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
        }
        
        queryOperation.queryCompletionBlock = {[unowned self] (cursor, error) -> Void in
            if let error = error {
                print("We have failed to get the data from iCloud Database")
            }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        
        }
        
        //Executing the Query
        publicDatabase.add(queryOperation)
        
//        publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            if let results = results {
//                print("We have completed the downloading of the Restaurant Data")
//                self.restaurants = results
//
//                //Will reload the icloud Table Data on main thread
//                DispatchQueue.main.sync {
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
    //Assigning Fetched Data to Discover Table Cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)
        
        //Configure the cell
        let restaurant = restaurants[indexPath.row]
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        
        //Setting the default image
        cell.imageView?.image = UIImage(named: "photo")
        
        //Fetehing the image fromm the Cloud Database in the background
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let fetchRecordsImageOperations = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
        fetchRecordsImageOperations.desiredKeys = ["image"]
        fetchRecordsImageOperations.queuePriority = .veryHigh
        
        fetchRecordsImageOperations.perRecordCompletionBlock = { [unowned self] (record, recordID, error) -> Void in
            if let error = error {
                    print("We have failed to obtain the record from the database.")
                }
        
            if let restaurantRecord = record,
            let image = restaurantRecord.object(forKey: "image"),
            let imageAsset = image as? CKAsset {
                if let imageData = try? Data.init(contentsOf: imageAsset.fileURL){
                    DispatchQueue.main.async {
                        cell.imageView?.image = UIImage(data: imageData)
                        cell.setNeedsLayout()
                    }
                }
            }
        }
            publicDatabase.add(fetchRecordsImageOperations)
            return cell
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }
    

}
