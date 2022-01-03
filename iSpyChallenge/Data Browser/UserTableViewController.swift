//
//  UserTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum UserSectionType: String {
    case attributes
    case relationships
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .attributes: return .none
        case .relationships: return .disclosureIndicator
        }
    }
}

enum UserRowType: String {
    case username
    case email
    case avatarLargeHref
    case avatarMediumHref
    case avatarThumbnailHref
    case challenges
    case matches
    case ratings
}

struct UserRow {
    let type: UserRowType
    let title: String?
    let detail: String?
}

struct UserSection {
    let type: UserSectionType
    let rows: [UserRow]
}

struct UserViewModel {
    let sections: [UserSection]
    
    init(user: User?) {
        let attributeSection = UserSection(type: .attributes, rows: [
            UserRow(type: .username, title: user?.username, detail: "username"),
            UserRow(type: .email, title: user?.email, detail: "email"),
            UserRow(type: .avatarLargeHref, title: user?.avatarLargeURL?.absoluteString, detail: "avatarLargeHref"),
            UserRow(type: .avatarMediumHref, title: user?.avatarMediumURL?.absoluteString, detail: "avatarMediumHref"),
            UserRow(type: .avatarThumbnailHref, title: user?.avatarThumbnailURL?.absoluteString, detail: "avatarThumbnailHref")
        ])
        
        let relationshipSection = UserSection(type: .relationships, rows: [
            UserRow(type: .challenges, title: "Challenges", detail: nil),
            UserRow(type: .matches, title: "Matches", detail: nil),
            UserRow(type: .ratings, title: "Ratings", detail: nil)
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class UserTableViewController: UITableViewController {
    var dataController: DataController?
    var user: User?
    var viewModel: UserViewModel?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserViewModel(user: user)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")!
        cell.textLabel?.text = row?.title
        cell.detailTextLabel?.text = row?.detail
        cell.accessoryType = section?.type.accessoryType ?? .none
        
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
        case .challenges:
            performSegue(withIdentifier: "ShowChallenges", sender: self)
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
        if let vc = viewController as? ChallengesTableViewController {
            vc.dataController = dataController
            vc.challenges = user?.challenges ?? []
        }
        
        if let vc = viewController as? MatchesTableViewController {
            vc.dataController = dataController
            
            if let user = user {
                vc.matches = dataController?.matches(createdBy: user) ?? []
            }
        }
        
        if let vc = viewController as? RatingsTableViewController {
            if let user = user {
                let ratings = dataController?.ratings(createdBy: user) ?? []
                vc.ratingsAndAssociatedUsers = dataController?.ratingsAndAssociatedUsers(for: ratings) ?? []
            }
        }
    }
}
