//
//  PhotoController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit

class PhotoController {
    private lazy var urlForPhotoStorage: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let photoPath = documentsDirectory.appendingPathComponent("iSpyPhotos")
        return photoPath
    }()
    
    init() throws {
        try setupPhotoDirectory()
    }
    
    func photo(withName name: String) -> UIImage? {
        do {
            let photoUrl = urlForPhoto(withName: name)
            let imageData = try Data(contentsOf: photoUrl)
            let image = UIImage(data: imageData)
            return image
        }
        catch {
            print("No photo for: \(name).")
            return nil
        }
    }
    
    func addPhoto(withName name: String, image: UIImage) {
        do {
            let imageData = image.jpegData(compressionQuality: 1.0)
            let url = urlForPhoto(withName: name)
            try imageData?.write(to: url, options: .atomic)
        }
        catch {
            print("Error adding photo: \(error.localizedDescription)")
        }
    }
    
    func removePhoto(withName name: String) {
        do {
            let url = urlForPhoto(withName: name)
            let fileManager = FileManager.default
            try fileManager.removeItem(at: url)
        }
        catch {
            print("Error removing photo: \(error.localizedDescription)")
        }
    }
    
    func removeAllPhotos() {
        do {
            let fileManager = FileManager.default
            let directoryPath = urlForPhotoStorage.path
            let filePaths = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for filePath in filePaths {
                try fileManager.removeItem(at: urlForPhotoStorage.appendingPathComponent(filePath))
            }
        }
        catch {
            print("Error removing all photos: \(error.localizedDescription)")
        }
    }
}

extension PhotoController {
    func setupPhotoDirectory() throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        let photoPath = urlForPhotoStorage.path
        
        if fileManager.fileExists(atPath: photoPath, isDirectory: &isDirectory) == false {
            try fileManager.createDirectory(atPath: photoPath, withIntermediateDirectories: true, attributes: nil)
        }
        else {
            print("Photo storage path already exists")
        }
    }
    
    func urlForPhoto(withName name: String) -> URL {
        let photoUrl = urlForPhotoStorage.appendingPathComponent(name).appendingPathExtension("jpg")
        return photoUrl
    }
}
