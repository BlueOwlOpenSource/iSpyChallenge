//
//  MatchTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum MatchSectionType: String {
    case attributes
    case relationships
}

enum MatchRowType: String {
    case latitude
    case longitude
    case photoHref
    case verified
    case challenge
    case user
}

struct MatchRow {
    let type: MatchRowType
    let title: String?
    let detail: String?
}

struct MatchSection {
    let type: MatchSectionType
    let rows: [MatchRow]
}

struct MatchViewModel {
    let sections: [MatchSection]
    
    init(match: Match) {
        let attributeSection = MatchSection(type: .attributes, rows: [
            MatchRow(type: .latitude, title: String(format: "%.5f", match.latitude), detail: "latitude"),
            MatchRow(type: .longitude, title: String(format: "%.5f", match.longitude), detail: "longitude"),
            MatchRow(type: .photoHref, title: match.photoImageName, detail: "photoHref"),
            MatchRow(type: .verified, title: match.verified ? "True" : "False", detail: "verified")
        ])
        
        let relationshipSection = MatchSection(type: .relationships, rows: [
            MatchRow(type: .challenge, title: "Challenge", detail: nil),
            MatchRow(type: .user, title: "User", detail: nil)
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class MatchTableViewController: UITableViewController {
    var dataController: DataController?
    var matchId: String?
    
    private var match: Match?
    private var viewModel: MatchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        registerForDataControllerNotifications()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.sections[safe: section]?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel?.sections[safe: indexPath.section]
        let row = section?.rows[safe: indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell")!
        cell.textLabel?.text = row?.title
        cell.detailTextLabel?.text = row?.detail
        
        if section?.type == .attributes {
            cell.accessoryType = .none
        }
        else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel?.sections[safe: section]?.type.rawValue
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel?
            .sections[safe: indexPath.section]?
            .rows[safe: indexPath.row]
        
        switch row?.type {
        case .challenge:
            performSegue(withIdentifier: "ShowChallenge", sender: self)
        case .user:
            performSegue(withIdentifier: "ShowUser", sender: self)
        default:
            break
        }
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
            
            if let match = match {
                vc.challengeId = dataController?
                    .challenge(for: match)?
                    .id
            }
        }
        
        if let vc = viewController as? UserTableViewController {
            vc.dataController = dataController
            
            if let match = match {
                vc.userId = dataController?
                    .user(identifiedBy: match.creatorID)?
                    .id
            }
        }
    }
    
    // MARK: Updating UI
    
    private func registerForDataControllerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .dataControllerDidUpdate, object: dataController)
    }
    
    @objc private func updateUI() {
        match = dataController?.allMatches.first(where: { $0.id == matchId })
        if let match = match {
            viewModel = MatchViewModel(match: match)
        }
        
        tableView.reloadData()
    }
}
