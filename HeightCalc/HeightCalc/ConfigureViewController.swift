//
//  ConfigureViewControler.swift
//  HeightCalc
//
//  Created by Max Batchelder on 8/12/22.
//

import Foundation
import UIKit

class ConfigureViewController: UITableViewController {
    
    var supportitems : Array<Item> = []

    weak var delegate: ItemConfigDelegate?
    
    override func viewDidLoad() {
        let head = delegate!.getCurHead()
        print(head)
        supportitems = delegate!.getSupportItems()
        print("got " + String(supportitems.count) + " support items")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int  {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        print("displaying " + String(supportitems.count) + " support items")
        return supportitems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configCell", for: indexPath)
        
        cell.textLabel!.text = supportitems[indexPath.row].name
        if (supportitems[indexPath.row].height != 0) {
            cell.detailTextLabel!.text = String(supportitems[indexPath.row].height) + "\""
        } else {
            cell.detailTextLabel!.text = String(supportitems[indexPath.row].minheight) + "\" - " + String(supportitems[indexPath.row].maxheight) + "\""
        }
        
        return cell
    }
}
