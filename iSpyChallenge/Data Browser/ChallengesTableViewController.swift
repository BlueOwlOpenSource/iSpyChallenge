//
//  ChallengesTableViewController.swift
//  iSpyChallenge
//
//

import UIKit
import CoreData

class ChallengesTableViewController: UITableViewController {
    var dataController: DataController!
    var challenges: [Challenge] = []
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        challenges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath)
        
        if let challenge = challenges[safe: indexPath.row] {
            cell.textLabel?.text = challenge.hint
            cell.detailTextLabel?.text = String(format: "(%.5f, %.5f)", challenge.latitude, challenge.longitude)
            cell.imageView?.image = UIImage(named: challenge.photoImageName)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowChallenge", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectProperties(viewController: segue.destination)
    }
    
    // MARK: - Injection
    
    func injectProperties(viewController: UIViewController) {
        if let vc = viewController as? ChallengeTableViewController {
            vc.dataController = dataController
            vc.challenge = challenges[safe: tableView.indexPathForSelectedRow?.row]
        }
    }
}
