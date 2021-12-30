//
//  RatingsTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class RatingsTableViewController: UITableViewController {
    var ratingsAndAssociatedUsers: [RatingAndAssociatedUser] = []
    
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
}
