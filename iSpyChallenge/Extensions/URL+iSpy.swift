//
//  URL+iSpy.swift
//  iSpyChallenge
//
//

import UIKit

extension URL {
    var loadedIntoImage: UIImage? {
        guard let data = try? Data(contentsOf: self) else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
