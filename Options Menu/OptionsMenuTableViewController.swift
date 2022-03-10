import UIKit

protocol OptionsMenuChangesNotifiable: class {
    func selectedItemChanged(options: CheckedFilter)
    func getList() -> Filter
    func getFilteredList() -> Filter
}

class CheckedFilter {
    var sources: [String:Bool] = [:]
    var categories: [String:Bool] = [:]
    var countries: [String:Bool] = [:]
}

class OptionsMenuTableViewController: UITableViewController {
    
    var checkedItems: CheckedFilter = CheckedFilter()
    public weak var delegate: OptionsMenuChangesNotifiable?
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in delegate!.getList().sources {
            checkedItems.sources[item] = false
        }
        for item in delegate!.getFilteredList().sources {
            checkedItems.sources[item] = true
        }
        for item in delegate!.getList().categories {
            checkedItems.categories[item] = false
        }
        for item in delegate!.getFilteredList().categories {
            checkedItems.categories[item] = true
        }
        for item in delegate!.getList().countries {
            checkedItems.countries[item] = false
        }
        for item in delegate!.getFilteredList().countries {
            checkedItems.countries[item] = true
        }
        
        tableView!.register(UINib(nibName: "OptionsMenuCell", bundle: nil), forCellReuseIdentifier: "OptionsMenuCell")
        setupTableViewAppearance()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.selectedItemChanged(options: checkedItems)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 180, height: tableView.contentSize.height)
    }
    
    // MARK: - Private Methods
    
    /**
     Setups initial appearance and behavior of TableView.
     */
    private func setupTableViewAppearance() {
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        tableView.separatorStyle = .none
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sources"
        case 1:
            return "Categories"
        default:
            return "Countries"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return delegate!.getList().sources.count
        case 1:
            return delegate!.getList().categories.count
        default:
            return delegate!.getList().countries.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsMenuCell", for: indexPath) as! OptionsMenuCell
        var rowData: String
        var isChecked: Bool
        
        switch indexPath.section {
        case 0:
            rowData = delegate!.getList().sources[indexPath.row]
            isChecked = checkedItems.sources[rowData] ?? false
        case 1:
            rowData = delegate!.getList().categories[indexPath.row]
            isChecked = checkedItems.categories[rowData] ?? false
        default:
            rowData = delegate!.getList().countries[indexPath.row]
            isChecked = checkedItems.countries[rowData] ?? false
        }
        
        
        cell.label.text = rowData
        if isChecked {
            cell.isChecked = true
            cell.checkButton.setImage(UIImage(systemName:"checkmark.square"), for: .normal)
        }
        
        cell.selectionStyle = .none
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OptionsMenuCell
        
        if cell.isChecked == false {
            cell.checkButton.setImage(UIImage(systemName:"checkmark.square"), for: .normal)
            cell.isChecked = true
            switch indexPath.section {
            case 0:
                checkedItems.sources[delegate!.getList().sources[indexPath.row]] = true
            case 1:
                checkedItems.categories[delegate!.getList().categories[indexPath.row]] = true
            default:
                checkedItems.countries[delegate!.getList().countries[indexPath.row]] = true
            }
            
        }
        else {
            cell.checkButton.setImage(UIImage(systemName:"square"), for: .normal)
            cell.isChecked = false
            switch indexPath.section {
            case 0:
                checkedItems.sources[delegate!.getList().sources[indexPath.row]] = false
            case 1:
                checkedItems.categories[delegate!.getList().categories[indexPath.row]] = false
            default:
                checkedItems.countries[delegate!.getList().countries[indexPath.row]] = false
            }
        }
    }
}
