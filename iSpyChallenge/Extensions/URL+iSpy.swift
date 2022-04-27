//
//  URL+iSpy.swift
//  iSpyChallenge
//
//

import UIKit

extension URL {
    func loadedIntoImage( closure: @escaping (UIImage?) -> Void ) {
        let task = URLSession.shared.dataTask(with: self) { (data, response, error) in
            DispatchQueue.main.async {
                closure( data != nil ? UIImage(data: data!) : nil )
            }
        }
        task.resume()
    }
}
