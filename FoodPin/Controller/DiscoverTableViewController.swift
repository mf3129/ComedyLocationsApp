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
    
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    
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
        
        //Pull To Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
        
        
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Formatting the navigation view controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor(red: 233, green: 76, blue: 60), NSAttributedString.Key.font: customFont ]
        }
        
        //Fetch Records From iCloud
        fetchRecordsFromCloud()
    }
    
    
    
    //Fetching Data From ICloud Database using convenience API
    @objc func fetchRecordsFromCloud(){
        
        //Removing records before refreshing
        restaurants.removeAll()
        tableView.reloadData()
        
        //Accessing the clodu container
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //Creating the query option using operational API
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "type", "location", "phone", "description"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
        }
        
        //Upon Query Completion
        queryOperation.queryCompletionBlock = {[unowned self] (cursor, error) -> Void in
            
            if let error = error {
                print("We have failed to get the data from iCloud Database")
            }
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing() //Disappearing the refresh control
                    }
                }
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
        
        let cellIdentifier = "DiscoverTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DiscoverTableViewCell
        
        
        //Configure the cell
        let restaurant = restaurants[indexPath.row]
        cell.comedyClubName?.text = restaurant.object(forKey: "name") as? String
        cell.locationName?.text = restaurant.object(forKey: "location") as? String
        cell.typeLabel?.text = restaurant.object(forKey: "type") as? String
        cell.summaryLabel?.text = restaurant.object(forKey: "description") as? String
        cell.phoneLabel?.text = restaurant.object(forKey: "phone") as? String
        
        //Setting the default image
        //cell.imageView?.image = UIImage(named: "photo")
        cell.mainImageDiscover.image = UIImage(named: "photo")
        
        //Checking to see if image is stored locally.
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) {
            print("Getting Image From The Cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.mainImageDiscover.image = UIImage(data: imageData)
            }
        } else {
        
        //Fetching the image fromm the Cloud Database in the background
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
                        cell.mainImageDiscover?.image = UIImage(data: imageData)
                        cell.setNeedsLayout()
                        }
                    self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                    }
                }
            }
            
            publicDatabase.add(fetchRecordsImageOperations)
        }
        
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
