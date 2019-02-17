//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by Makan Fofana on 2/2/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import CoreData

class NewRestaurantController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var restaurant: RestaurantMO!
    @IBOutlet weak var photoImageView: UIImageView!
    
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
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedString.Key.font: customFont ]
        }
        
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        if (nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" ){
            
            let ErrorController = UIAlertController(title: "Ayyyeee", message: "You forgot to enter text for one or more fields.", preferredStyle: .alert)
            
            let errorAlert = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
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
            
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
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
    

    
    
    
    
}
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


