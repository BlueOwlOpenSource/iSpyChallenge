//
//  MatchesTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class MatchesTableViewController: UITableViewController {
    enum ListType {
        case matchesForUser(userId: String)
        case matchesForChallenge(challengeId: String)
    }
    
    var dataController: DataController?
    var listType: ListType?
    
    private var matches: [Match] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        registerForDataControllerNotifications()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        
        if let match = matches[safe: indexPath.row] {
            cell.textLabel?.text = "Match"
            cell.detailTextLabel?.text = String(format: "(%.5f, %.5f)", match.latitude, match.longitude)
            cell.imageView?.image = UIImage(named: match.photoImageName)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMatch", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectProperties(viewController: segue.destination)
    }
    
    // MARK: - Injection
    
    func injectProperties(viewController: UIViewController) {
        if let vc = viewController as? MatchTableViewController {
            vc.dataController = dataController
            vc.matchId = matches[safe: tableView.indexPathForSelectedRow?.row]?.id
        }
    }
    
    // MARK: Updating UI
    
    private func registerForDataControllerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .dataControllerDidUpdate, object: dataController)
    }
    
    @objc private func updateUI() {
        switch listType {
        case .matchesForUser(let userId):
            matches = dataController?
                .matches(createdBy: userId) ?? []
            
        case .matchesForChallenge(let challengeId):
            matches = dataController?
                .allChallenges
                .first(where: { $0.id == challengeId })?
                .matches ?? []
            
        case nil:
            break
        }
        
        tableView.reloadData()
    }
}
