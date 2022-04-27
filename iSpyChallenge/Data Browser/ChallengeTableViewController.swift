//
//  ChallengeTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum ChallengeSectionType: String {
    case attributes
    case relationships
}

enum ChallengeRowType: String {
    case hint
    case latitude
    case longitude
    case photoHref
    case creator
    case matches
    case ratings
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
    
    init(challenge: Challenge) {
        let attributeSection = ChallengeSection(type: .attributes, rows: [
            ChallengeRow(type: .hint, title: challenge.hint, detail: "hint"),
            ChallengeRow(type: .latitude, title: String(format: "%.5f", challenge.latitude), detail: "latitude"),
            ChallengeRow(type: .longitude, title: String(format: "%.5f", challenge.longitude), detail: "longitude"),
            ChallengeRow(type: .photoHref, title: challenge.photoImageName, detail: "photoHref")
        ])
        
        let relationshipSection = ChallengeSection(type: .relationships, rows: [
            ChallengeRow(type: .creator, title: "Creator", detail: nil),
            ChallengeRow(type: .matches, title: "Matches", detail: nil),
            ChallengeRow(type: .ratings, title: "Ratings", detail: nil),
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class ChallengeTableViewController: UITableViewController {
    var dataController: DataController?
    var challengeId: String?
    
    private var challenge: Challenge?
    private var viewModel: ChallengeViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        registerForDataControllerNotifications()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.sections[safe: section]?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel?.sections[safe: indexPath.section]
        let row = section?.rows[safe: indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell")!
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
        case .creator:
            performSegue(withIdentifier: "ShowUser", sender: self)
        case .matches:
            performSegue(withIdentifier: "ShowMatches", sender: self)
        case .ratings:
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
        if let vc = viewController as? UserTableViewController {
            vc.dataController = dataController
            
            if let challenge = challenge {
                vc.userId = dataController?.user(identifiedBy: challenge.creatorID)?.id
            }
        }
        
        if let vc = viewController as? MatchesTableViewController {
            vc.dataController = dataController
            
            if let challenge = challenge {
                vc.listType = .matchesForChallenge(challengeId: challenge.id)
            }
        }
        
        if let vc = viewController as? RatingsTableViewController {
            vc.dataController = dataController
            
            if let challenge = challenge {
                vc.listType = .ratingsForChallenge(challengeId: challenge.id)
            }
        }
    }
    
    // MARK: Updating UI
    
    private func registerForDataControllerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .dataControllerDidUpdate, object: dataController)
    }
    
    @objc private func updateUI() {
        challenge = dataController?
            .allChallenges
            .first(where: { $0.id == challengeId })
        
        if let challenge = challenge {
            viewModel = ChallengeViewModel(challenge: challenge)
        }
        
        tableView.reloadData()
    }
}
