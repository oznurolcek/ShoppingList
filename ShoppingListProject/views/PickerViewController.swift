//
//  PickerViewController.swift
//  ShoppingListProject
//
//  Created by Öznur Ölçek on 1.08.2023.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var filterPickerView: UIPickerView!
    
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        contentView.addGestureRecognizer(gestureRecognizer)

    }
    
    @IBAction func doneButtonAct(_ sender: Any) {
        print("deneme")
    }
    
    @IBAction func cancelButtonAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
}


