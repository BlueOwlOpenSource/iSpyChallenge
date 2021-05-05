//
//  MatchTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum MatchSectionType: String {
    case Attributes
    case Relationships
}

enum MatchRowType: String {
    case Latitude
    case Longitude
    case PhotoHref
    case Verified
    case Challenge
    case Player
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
    
    init(match: Match?) {
        let attributeSection = MatchSection(type: .Attributes, rows: [
            MatchRow(type: .Latitude, title: String(format: "%.5f", match!.latitude), detail: "latitude"),
            MatchRow(type: .Longitude, title: String(format: "%.5f", match!.longitude), detail: "longitude"),
            MatchRow(type: .PhotoHref, title: match?.photoHref, detail: "photoHref"),
            MatchRow(type: .Verified, title: match!.verified ? "True" : "False", detail: "verified")
        ])
        
        let relationshipSection = MatchSection(type: .Relationships, rows: [
            MatchRow(type: .Challenge, title: "Challenge", detail: nil),
            MatchRow(type: .Player, title: "Player", detail: nil)
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class MatchTableViewController: UITableViewController, DataControllerInjectable, PhotoControllerInjectable, MatchInjectable {
    var dataController: DataController!
    var photoController: PhotoController!
    var match: Match?
    var viewModel: MatchViewModel?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MatchViewModel(match: match)
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel?.sections[section]
        return section?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel?.sections[indexPath.section]
        let row = section?.rows[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell")!
        cell.textLabel?.text = row?.title
        cell.detailTextLabel?.text = row?.detail
        
        if section?.type == .Attributes {
            cell.accessoryType = .none
        }
        else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel?.sections[section]
        return section?.type.rawValue
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = viewModel?.sections[indexPath.section]
        let row = section?.rows[indexPath.row]
        
        switch row?.type {
        case .Challenge:
            performSegue(withIdentifier: "ShowChallenge", sender: self)
        case .Player:
            performSegue(withIdentifier: "ShowPlayer", sender: self)
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
        if let vc = viewController as? DataControllerInjectable {
            vc.dataController = self.dataController
        }
        
        if let vc = viewController as? PhotoControllerInjectable {
            vc.photoController = self.photoController
        }
        
        if let vc = viewController as? ChallengeInjectable {
            vc.challenge = self.match?.challenge
        }
        
        if let vc = viewController as? UserInjectable {
            vc.user
                = self.match?.player
        }
    }

}
