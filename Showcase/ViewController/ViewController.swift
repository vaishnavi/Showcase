//
//  ViewController.swift
//  Showcase
//
//  Created by Vaishnavi on 12/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var items = [Items]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTableListItems()
        // Do any additional setup after loading the view, typically from a nib.
    }

    private func fetchTableListItems() {
        Manager.shared.tableList { itemList in
            if let list = itemList {
                self.items = list
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = CustomTableViewCell.fromNib()  else { return  UITableViewCell() }
        cell.configure(forItem: items[indexPath.row])
        //cell.textLabel?.text = items[indexPath.row].title
        return cell
    }

}

