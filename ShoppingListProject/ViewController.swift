//
//  ViewController.swift
//  ShoppingListProject
//
//  Created by Öznur Ölçek on 13.04.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var brandArray = [String]()
    var priceArray = [Int]()
    var imageArray = [Data]()

    
    var selectedProduct = ""
    var selectedProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addProduct))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 160.0/255.0, green: 118.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        
        
       
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 215.0/255.0, green: 187.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("Data entered."), object: nil)
    }
    
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                    if let brand = result.value(forKey: "brand") as? String {
                        brandArray.append(brand)
                    }
                    if let price = result.value(forKey: "price") as? Int {
                        priceArray.append(price)
                    }
                    if let image = result.value(forKey: "image") as? Data {
                        imageArray.append(image)
                    }
                }
            }
            tableView.reloadData()
        } catch {
            print("Error")
        }
        
    }
    
    @objc func addProduct() {
        selectedProduct = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.selectedProduct = selectedProduct
            destinationVC.selectedProductUUID = selectedProductUUID
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productTVCell", for: indexPath) as! ProductsCell
        cell.productImage.image = UIImage(data: imageArray[indexPath.row]) 
        cell.brandLabel.text = "Brand: \(brandArray[indexPath.row])"
        cell.priceLabel.text = "Price: \(String(priceArray[indexPath.row])) ₺"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProduct = nameArray[indexPath.row]
        selectedProductUUID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let uuidString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
        
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("Error")
                                }
                                break
                                
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }
    }
}

