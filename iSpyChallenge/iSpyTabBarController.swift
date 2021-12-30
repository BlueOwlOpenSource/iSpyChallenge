//
//  iSpyTabBarController.swift
//  iSpyChallenge
//

import UIKit
import CoreData

class iSpyTabBarController: UITabBarController {
    private lazy var dataController: DataController = {
        DataController(apiService: APIService(), delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBrowserViewController?.dataController = dataController
        
        dataController.loadAllData()
        updateAllViewControllersWithData()
    }
}

extension iSpyTabBarController: DataControllerDelegate {
    func dataControllerDidUpdate(_ dataController: DataController) {
        DispatchQueue.main.async {
            self.updateAllViewControllersWithData()
        }
    }
}

private extension iSpyTabBarController {
    // Should be called only on the main thread
    func updateAllViewControllersWithData() {
        dataBrowserViewController?.users = dataController.allUsers
    }
    
    var dataBrowserViewController: DataBrowserTableViewController? {
        viewControllers?
            .compactMap { ($0 as? UINavigationController)?.viewControllers.first as? DataBrowserTableViewController }
            .first
    }
}
