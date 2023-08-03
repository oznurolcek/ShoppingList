//
//  WebsiteViewController.swift
//  ShoppingListProject
//
//  Created by Öznur Ölçek on 3.08.2023.
//

import UIKit
import WebKit

class WebsiteViewController: UIViewController {

    @IBOutlet weak var linkWebView: WKWebView!
    
    var link: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: link!)!
        linkWebView.load(URLRequest(url: url))

    }

}
