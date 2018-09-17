//
//  WikiResultTableViewController.swift
//  WikiApp

//  Created by Maparthi Venga on 09/16/18.
//  Copyright © 2018 Maparthi Venga. All rights reserved.
//
import UIKit

class WikiResultTableViewController: UITableViewController {
    
    var wikiResults : Wiki?
    let searchController = UISearchController(searchResultsController: nil)
    let networkHandler = NetworkHandler()
    
    struct  Constants {
        static let cellidentifier = "WikiResultTableViewCell"
        static let title = "Wiki Search"
        static let searchText = "Wiki Search, enter 3 or more char"
        static let alertTitle = "Alert!"
        static let alertMessageText = "This will delete all the cache data, including cached photos"
        static let cancelTitle = "Cancel"
        static let okayTitle = "Okay"
        
        static let segueIdentifier = "webViewSegue"        
    }
    
    fileprivate func intialSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constants.searchText
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.isActive = true
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        self.title = Constants.title
        if let results = networkHandler.getSearchSuggestionData() {
            self.wikiResults = results
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func getWikiResults(withSearchKey key : String) {
        networkHandler.getWikiData(fromKey: key) { (wiki) in
            if let wiki = wiki {
                self.wikiResults = wiki
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let wikiResults = wikiResults else { return 0 }
        guard let pages = wikiResults.query?.pages else { return 0 }
        return pages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellidentifier, for: indexPath) as? WikiResultTableViewCell {
            guard let pages = wikiResults?.query?.pages else { return UITableViewCell() }
            if pages.indices.contains(indexPath.row) {
                cell.pageResult = pages[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: Constants.segueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdentifier, let controller = segue.destination as? WikiDetailViewController, let indexPath = sender as? IndexPath {
            guard let pages = wikiResults?.query?.pages else { return }
            if pages.indices.contains(indexPath.row) {
                let pageResult = pages[indexPath.row]
                guard let pageID = pageResult.pageid else { return }
                controller.pageTitle = pageResult.title
                controller.pageId = "\(pageID)"
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) { //FIXME : API call will be added here
        if searchBarIsEmpty() {
            self.wikiResults = nil
            if let results = networkHandler.getSearchSuggestionData() {
                self.wikiResults = results
            }
            tableView.reloadData()
        } else {
            self.getWikiResults(withSearchKey: searchText)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    @IBAction func deleteCacheAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Constants.alertTitle, message: Constants.alertMessageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.cancelTitle, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: Constants.okayTitle, style: .destructive) { (action) in
            WikiCache.shared.clearData()
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension WikiResultTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
}

extension WikiResultTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let text = searchBar.text {
            filterContentForSearchText(text)
        }
    }
}
