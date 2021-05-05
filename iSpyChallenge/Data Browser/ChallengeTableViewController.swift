//
//  ChallengeTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum ChallengeSectionType: String {
    case Attributes
    case Relationships
}

enum ChallengeRowType: String {
    case Hint
    case Latitude
    case Longitude
    case PhotoHref
    case Creator
    case Matches
    case Ratings
}

struct ChallengeRow {
    let type: ChallengeRowType
    let title: String?
    let detail: String?
}

struct ChallengeSection {
    let type: ChallengeSectionType
    let rows: [ChallengeRow]
}

struct ChallengeViewModel {
    let sections: [ChallengeSection]
    
    init(challenge: Challenge?) {
        let attributeSection = ChallengeSection(type: .Attributes, rows: [
            ChallengeRow(type: .Hint, title: challenge?.hint, detail: "hint"),
            ChallengeRow(type: .Latitude, title: String(format: "%.5f", challenge!.latitude), detail: "latitude"),
            ChallengeRow(type: .Longitude, title: String(format: "%.5f", challenge!.longitude), detail: "longitude"),
            ChallengeRow(type: .PhotoHref, title: challenge?.photoHref, detail: "photoHref")
        ])
        
        let relationshipSection = ChallengeSection(type: .Relationships, rows: [
            ChallengeRow(type: .Creator, title: "Creator", detail: nil),
            ChallengeRow(type: .Matches, title: "Matches", detail: nil),
            ChallengeRow(type: .Ratings, title: "Ratings", detail: nil),
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class ChallengeTableViewController: UITableViewController, DataControllerInjectable, PhotoControllerInjectable, ChallengeInjectable {
    var dataController: DataController!
    var photoController: PhotoController!
    var challenge: Challenge?
    var viewModel: ChallengeViewModel?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ChallengeViewModel(challenge: challenge)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell")!
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
        case .Creator:
            performSegue(withIdentifier: "ShowUser", sender: self)
        case .Matches:
            performSegue(withIdentifier: "ShowMatches", sender: self)
        case .Ratings:
            performSegue(withIdentifier: "ShowRatings", sender: self)
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
        
        if let vc = viewController as? UserInjectable {
            vc.user = self.challenge?.creator
        }
        
        if let vc = viewController as? ChallengeInjectable {
            vc.challenge = self.challenge
        }
    }

}
