//
//  Cell.swift
//  ToDoList
//
//  Created by Леонид Лукашевич on 11.02.2021.
//

import UIKit

class Cell: UITableViewCell {
    
    @IBOutlet weak var picture: UIImageView! {
        didSet {
            picture.layer.cornerRadius = picture.layer.frame.height / 4
            picture.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
