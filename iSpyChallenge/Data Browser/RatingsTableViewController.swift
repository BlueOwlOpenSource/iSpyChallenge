//
//  RatingsTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class RatingsTableViewController: UITableViewController {
    enum ListType {
        case ratingsCreatedByUser(userId: String)
        case ratingsForChallenge(challengeId: String)
    }
    
    var dataController: DataController?
    var listType: ListType?
    
    private var ratingsAndAssociatedUsers: [RatingAndAssociatedUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        registerForDataControllerNotifications()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ratingsAndAssociatedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath)
        
        if let ratingAndAssociatedUser = ratingsAndAssociatedUsers[safe: indexPath.row] {
            cell.textLabel?.text = String(format: "%i", ratingAndAssociatedUser.rating.stars)
            cell.detailTextLabel?.text = ratingAndAssociatedUser.user.username
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: Updating UI
    
    private func registerForDataControllerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .dataControllerDidUpdate, object: dataController)
    }
    
    @objc private func updateUI() {
        switch listType {
        case .ratingsCreatedByUser(let userId):
            let ratings = dataController?.ratings(createdBy: userId) ?? []
            ratingsAndAssociatedUsers = dataController?
                .ratingsAndAssociatedUsers(for: ratings) ?? []
            
        case .ratingsForChallenge(let challengeId):
            if let challenge = dataController?.allChallenges.first(where: { $0.id == challengeId }) {
                ratingsAndAssociatedUsers = dataController?
                    .ratingsAndAssociatedUsers(for: challenge.ratings) ?? []
            }

        case nil:
            break
        }
        
        tableView.reloadData()
    }
}
