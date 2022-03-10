//
//  TableViewCell.swift
//  NewsApi
//
//  Created by Jerne Hatchet on 02.03.2022.
//

import UIKit

protocol CellDelegate: class {
    func getRow(row: Int)
}

class TableViewCell: UITableViewCell {

    public weak var delegate: CellDelegate?
    
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    var row: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toFavClick(_ sender: Any) {
        delegate?.getRow(row: row)
    }
    
}
