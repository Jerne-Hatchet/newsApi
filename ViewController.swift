//
//  ViewController.swift
//  NewsApi
//
//  Created by Jerne Hatchet on 02.03.2022.
//

import UIKit
import CoreData

class NewsItem {
    var source: String
    var author: String
    var title: String
    var description: String
    var image: String
    var url: String
    var category: String
    var country: String
    var publishedAt: Int
    
    init(source: String, author: String, title: String, description: String, image: String, url: String, category: String, country: String, publishedAt: Int) {
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.image = image
        self.url = url
        self.category = category
        self.country = country
        self.publishedAt = publishedAt
    }
}

class Filter {
    var sources: [String] = []
    var categories: [String] = []
    var countries: [String] = []
}

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    
    
    var data: [NewsItem]?
    var currentList: [NewsItem]?
    var favList: [NewsItem] = []
    var favorites: [Favorites] = []
    
    var searchText: String = ""
    var isSearching: Bool = false
    var filter: Filter = Filter()
    var filteredItems: Filter = Filter()
    var isFiltered: Bool = false
    var isSorting: Bool = false
    
    var countRow = 3
    
    var refreshControl:UIRefreshControl!
    var fetchingMore: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [NewsItem(source: "Source1", author: "Author1", title: "Title1", description: "Ukraine Photo 3", image: "https://tinyurl.com/y8cmgtgp", url: "https://google.com", category: "Photo", country: "Ukraine", publishedAt: 3),NewsItem(source: "Source2", author: "Author2", title: "Title2", description: "Ukraine Fashion 4", image: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png", url: "https://facebook.com", category: "Fashion", country: "Ukraine", publishedAt: 4),NewsItem(source: "Source3", author: "Author3", title: "Title3", description: "USA Photo 2", image: "https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg", url: "https://instagram.com", category: "Photo", country: "USA", publishedAt: 2), NewsItem(source: "Source4", author: "Author4", title: "Title4", description: "Ukraine Fashion 1", image: "https://tinyurl.com/y8cmgtgp", url: "https://google.com", category: "Fashion", country: "Ukraine", publishedAt: 1),NewsItem(source: "Source5", author: "Author5", title: "Title5", description: "Ukraine fashion 4", image: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png", url: "https://facebook.com", category: "Fashion", country: "Ukraine", publishedAt: 4),NewsItem(source: "Source6", author: "Author6", title: "Title6", description: "Ukraine Fashion 3", image: "https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg", url: "https://instagram.com", category: "Fashion", country: "Ukraine", publishedAt: 3)]
        
        currentList = data
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        let loadingCell = UIView(frame: CGRect(x:0, y:0, width: view.frame.width, height: 100))
        let label = UILabel(frame: loadingCell.bounds)
        label.text = "More"
        loadingCell.addSubview(label)
        
        let loadingCellTapGesture = UITapGestureRecognizer(target: self, action: #selector(onLoadingCellTap))
        loadingCell.addGestureRecognizer(loadingCellTapGesture)

        
        tableView.tableFooterView = loadingCell
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        tableView.refreshControl = refreshControl
        
        fillSetsForFilter()
        
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        onLoadingCellTap()
        sender.endRefreshing()
    }
    
    @objc func onLoadingCellTap() {
        if countRow < currentList?.count ?? 0 {
            countRow = countRow+3
        }
       
    }
    
    func setCurrentList() {
        currentList = data
        
        if isFiltered {
            var filteredList:[NewsItem] = []
            for newsItem in self.currentList! {
                var checked: Int = 0
                if filteredItems.sources.count > 0 {
                    for sourceItem in filteredItems.sources {
                        if newsItem.source == sourceItem {
                            checked += 1
                        }
                    }
                } else {
                    checked += 1
                }
                if filteredItems.categories.count > 0 {
                    for categoryItem in filteredItems.categories {
                        if newsItem.category == categoryItem {
                            checked += 1
                        }
                    }
                } else {
                    checked += 1
                }
                if filteredItems.countries.count > 0 {
                    for countryItem in filteredItems.countries {
                        if newsItem.country == countryItem {
                            checked += 1
                        }
                    }
                } else {
                    checked += 1
                }
                if checked > 2 {
                    filteredList.append(newsItem)
                }
            }
            currentList = filteredList
        }
        
        if isSearching {
            currentList = currentList!.filter({$0.title.lowercased().contains(searchText.lowercased())})
        }
        
        if isSorting {
            currentList = currentList!.sorted(by: {$0.publishedAt < $1.publishedAt})
        }
    }
    
    func fillSetsForFilter() {
        var sourcesSet: Set<String> = []
        var categoriesSet: Set<String> = []
        var countriesSet: Set<String> = []
        for dataElement in data! {
            sourcesSet.insert(dataElement.source)
            categoriesSet.insert(dataElement.category)
            countriesSet.insert(dataElement.country)
        }
        self.filter.sources = Array(sourcesSet)
        self.filter.categories = Array(categoriesSet)
        self.filter.countries = Array(countriesSet)
    }
    
    @IBAction func onFilterButtonClick(_ sender: Any) {
        setOptionsMenu()
    }
    @IBAction func onSortButtonClick(_ sender: Any) {
        isSorting = !isSorting
        setCurrentList()
        updateList()
    }
    
    @IBAction func onFavoriteButtonClick(_ sender: Any) {
        let rootVC = FavoritesViewController()
        //rootVC.favoriteList = favList ?? []
        let navVC = UINavigationController(rootViewController: rootVC)
        self.present(navVC, animated: true)
    }
    
    func saveToFavorites() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context) else {return}
        
        let favorite = Favorites(entity: entity, insertInto: context)
        favorite.title = favList[favList.count-1].title
        favorite.newsDescription = favList[favList.count-1].description
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, CellDelegate {
    func getRow(row: Int) {
        favList.append(currentList![row])
        saveToFavorites()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.source.text = currentList![indexPath.row].source
        cell.author.text = currentList![indexPath.row].author
        cell.title.text = currentList![indexPath.row].title
        cell.newsDescription.text = currentList![indexPath.row].description
        cell.newsImage.imageFrom(url: URL(string:currentList![indexPath.row].image)!)
        cell.row = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if countRow > currentList?.count ?? 0 {
            return currentList?.count ?? 0
        } else {
            return countRow
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = data![indexPath.row].url
        let rootVC = WebViewController()
        rootVC.url = URL(string: url)!
        let navVC = UINavigationController(rootViewController: rootVC)
        self.present(navVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func updateList() {
        self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                beginBatchFatch()
            }
        }
    }
    
    func beginBatchFatch() {
        fetchingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
            self.onLoadingCellTap()
            self.updateList()
            self.fetchingMore = false
        })
    }
}

extension ViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText == "" {
            isSearching = false
            setCurrentList()
        } else {
            isSearching = true
            setCurrentList()
        }
        updateList()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension ViewController:  UIPopoverPresentationControllerDelegate, OptionsMenuChangesNotifiable {
    func selectedItemChanged(options: CheckedFilter) {
        filterByCloud(options: options)
    }
    
    func getList() -> Filter {
        return filter
    }
    
    func getFilteredList() -> Filter {
        return filteredItems
    }
    
    @objc func setOptionsMenu() {
        let popVC = storyboard?.instantiateViewController(withIdentifier: "OptionsMenuView") as! OptionsMenuTableViewController
        popVC.modalPresentationStyle = .popover
        popVC.delegate = self
        let popoverVC = popVC.popoverPresentationController
        popoverVC?.sourceView = filterButton
        popoverVC?.delegate = self
        popoverVC?.permittedArrowDirections = .up
        
        self.present(popVC, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func filterByCloud(options: CheckedFilter) {
        filteredItems.sources.removeAll()
        filteredItems.categories.removeAll()
        filteredItems.countries.removeAll()
        for (item, isChecked) in options.sources {
             if isChecked {
                filteredItems.sources.append(item)
             }
         }
        for (item, isChecked) in options.categories {
             if isChecked {
                filteredItems.categories.append(item)
             }
         }
        for (item, isChecked) in options.countries {
             if isChecked {
                filteredItems.countries.append(item)
             }
         }
        if filteredItems.sources.isEmpty && filteredItems.categories.isEmpty && filteredItems.countries.isEmpty {
            isFiltered = false
            setCurrentList()
        }
        else {
            isFiltered = true
            setCurrentList()
        }
        updateList()
    }
}
