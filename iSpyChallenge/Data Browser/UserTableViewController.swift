//
//  UserTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

enum UserSectionType: String {
    case Attributes
    case Relationships
}

enum UserRowType: String {
    case Username
    case Email
    case AvatarLargeHref
    case AvatarMediumHref
    case AvatarThumbnailHref
    case Challenges
    case Matches
    case Ratings
}

struct UserRow {
    let type: UserRowType
    let title: String
    let detail: String?
}

struct UserSection {
    let type: UserSectionType
    let rows: [UserRow]
}

struct UserViewModel {
    let sections: [UserSection]
    
    init(user: User) {
        let attributeSection = UserSection(type: .Attributes, rows: [
            UserRow(type: .Username, title: user.username, detail: "username"),
            UserRow(type: .Email, title: user.email, detail: "email"),
            UserRow(type: .AvatarLargeHref, title: user.avatarLargeHref, detail: "avatarLargeHref"),
            UserRow(type: .AvatarMediumHref, title: user.avatarMediumHref, detail: "avatarMediumHref"),
            UserRow(type: .AvatarThumbnailHref, title: user.avatarThumbnailHref, detail: "avatarThumbnailHref")
        ])
        
        let relationshipSection = UserSection(type: .Relationships, rows: [
            UserRow(type: .Challenges, title: "Challenges", detail: nil),
            UserRow(type: .Matches, title: "Matches", detail: nil),
            UserRow(type: .Ratings, title: "Ratings", detail: nil)
        ])
        
        self.sections = [attributeSection, relationshipSection]
    }
}

class UserTableViewController: UITableViewController, DataControllerInjectable, PhotoControllerInjectable {
    var dataController: DataController!
    var photoController: PhotoController!
    var user: User!
    var viewModel: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserViewModel(user: user)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")!
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
        case .Challenges:
            performSegue(withIdentifier: "ShowChallenges", sender: self)
        case .Matches:
            performSegue(withIdentifier: "ShowMatches", sender: self)
        case .Ratings:
            performSegue(withIdentifier: "ShowChallenges", sender: self)
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
        
        if let vc = viewController as? ChallengesTableViewController {
            vc.user = user
        }
        
        if let vc = viewController as? MatchesTableViewController {
            vc.user = user
        }
    }

}
