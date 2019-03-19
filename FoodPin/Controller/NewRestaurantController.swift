//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by Makan Fofana on 2/2/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import CoreData
import CloudKit


class NewRestaurantController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var restaurant: RestaurantMO!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var newRestaurant: UINavigationItem!
    
    
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
        
        @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }

    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView: RoundedTextField! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 35.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 210, green: 154, blue: 109), NSAttributedString.Key.font: customFont ]
        }
        
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        if (nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" ){
            
            let ErrorController = UIAlertController(title: NSLocalizedString("Hello", comment: "Hello") , message: NSLocalizedString("You forgot to enter text for one or more fields.", comment: "You forgot to enter text for one or more fields."), preferredStyle: .alert)
            
            let errorAlert = UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay"), style: .cancel, handler: nil)
            
            ErrorController.addAction(errorAlert)
            
            //Displaying the menu
            present(ErrorController, animated: true, completion: nil)
            
            
        } else {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
            
            //Stroring restaurant object models into
                restaurant.name = nameTextField.text
                restaurant.type = typeTextField.text
                restaurant.location = addressTextField.text
                restaurant.phone = phoneTextField.text
                restaurant.summary = descriptionTextView.text
                restaurant.isVisited = false
            
                if let restaurantImage = photoImageView.image {
                    restaurant.image = restaurantImage.pngData()
                }
            
                print("Saving data to context...")
                appDelegate.saveContext()
                
                //Calling the save method to iCloud 
                saveRecordToCloud(restaurant: restaurant)
                
                dismiss(animated: true, completion: nil)
            
//            //Hard Coded Database | Pre-Core Data
//            print("Name: " + nameTextField.text!)
//            print("Type: " + typeTextField.text!)
//            print("Location: " + addressTextField.text!)
//            print("Phone: " + phoneTextField.text!)
//            print("Description: " + descriptionTextView.text!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
            return true
    }
    
    
    // Choosing Photo or Taking Picture In New Restaurant View Controller
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: .actionSheet)
            
            
            let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            
            
            let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Photo Library"), style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            
            //For iPad Device
            
            if let popOverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popOverController.sourceView = cell
                    popOverController.sourceRect = cell.bounds
                }
            }
            
            present(photoSourceRequestController, animated: true, completion: nil)
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                photoImageView.image = selectedImage
                photoImageView.contentMode = .scaleAspectFill
                photoImageView.clipsToBounds = true
        }
        
            let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
                leadingConstraint.isActive = true
        
            
            let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
                trailingConstraint.isActive = true
        
            let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
                topConstraint.isActive = true
        
            let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
                bottomConstraint.isActive = true
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func saveRecordToCloud(restaurant: RestaurantMO!) -> Void {
       
        //Preparing To Save The Record
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        record.setValue(restaurant.summary, forKey: "description")
        
        let imageData = restaurant.image! as Data
        
        //Resizing the image
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)!
        
        
        //Write image to local file
        let imageFilePath = NSTemporaryDirectory() + restaurant.name!
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        
        
        //Creating image assets for uploading
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        //Get the Public Database
        //let customContainer = CKContainer(identifier: "iCloud.com.MakanFofana.FoodPin")
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        //Saving Record To iCloud
        publicDatabase.save(record) { (record, error) in
            try? FileManager.default.removeItem(at: imageFileURL)
            guard let record = record else {
                print("Error saving record: ", error)
                return
            }
            print("Successfully saved record: ", record)
        }

    }

}

