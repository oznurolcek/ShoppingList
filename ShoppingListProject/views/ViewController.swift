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
    
    var productModalArr = [ProductModel]()

    
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
        
        productModalArr.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    guard let name = result.value(forKey: "name") as? String else {
                        return
                    }
                    guard let id = result.value(forKey: "id") as? UUID else {
                        return
                    }
                    guard let brand = result.value(forKey: "brand") as? String else {
                        return
                    }
                    guard let price = result.value(forKey: "price") as? Int else {
                        return
                    }
                    guard let image = result.value(forKey: "image") as? Data else {
                        return
                    }
                    
                    productModalArr.append(ProductModel(name: name, id: id, brand: brand, price: price, image: image))
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
        return productModalArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productTVCell", for: indexPath) as! ProductsCell
        cell.productImage.image = UIImage(data: productModalArr[indexPath.row].image)
        cell.brandLabel.text = "Brand: \(productModalArr[indexPath.row].brand)"
        cell.priceLabel.text = "Price: \(String(productModalArr[indexPath.row].price)) ₺"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProduct = productModalArr[indexPath.row].name
        selectedProductUUID = productModalArr[indexPath.row].id
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let uuidString = productModalArr[indexPath.row].id.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
        
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == productModalArr[indexPath.row].id {
                                context.delete(result)
                                productModalArr.remove(at: indexPath.row)
                                
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

