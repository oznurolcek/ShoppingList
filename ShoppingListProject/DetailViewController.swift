//
//  DetailViewController.swift
//  ShoppingListProject
//
//  Created by Öznur Ölçek on 13.04.2023.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    var selectedProduct = ""
    var selectedProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProduct != "" {
            
            saveButton.isHidden = true
            
            if let uuidString = selectedProductUUID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                            }
                            
                            if let brand = result.value(forKey: "brand") as? String {
                                brandTextField.text = brand
                            }
                            
                            if let size = result.value(forKey: "size") as? String {
                                sizeTextField.text = size
                            }
                            
                            if let price = result.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("Error")
                }
                
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            brandTextField.text = ""
            sizeTextField.text = ""
            priceTextField.text = ""
            
            
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let ImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        imageView.addGestureRecognizer(ImageGestureRecognizer)

    }
    
    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        
        shopping.setValue(nameTextField.text, forKey: "name")
        shopping.setValue(brandTextField.text, forKey: "brand")
        shopping.setValue(sizeTextField.text, forKey: "size")
        if let price = Int(priceTextField.text!) {
            shopping.setValue(price, forKey: "price")
        }
        shopping.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("Data entered."), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc func changeImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    

}
