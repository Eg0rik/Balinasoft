//
//  ImagePicker.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import AVFoundation
import UIKit
import PhotosUI

protocol PhotoPickerDelegate: UIViewController {
    func picker(_ picker: PhotoPicker, didSelect image: UIImage)
}

protocol PhotoPicker: NSObject {
    var delegate: PhotoPickerDelegate? { get set }
    
    func present()
}

extension PhotoPicker {
    func pleaseGiveAccessInSettings(for source: String, typeAccess: String = "") {
        let alertVC = UIAlertController(title: "No access to the \(source)", message: "Please provide \(typeAccess)access in settings", preferredStyle: .alert)
        
        alertVC.addAction(
            UIAlertAction(title: "Settings", style: .default) { action in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        )
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        delegate?.present(alertVC, animated: true)
    }
}

//MARK: - PhtotoCameraPicker
final class PhotoCameraPicker: NSObject, PhotoPicker {
    
    weak var delegate: PhotoPickerDelegate?
    
    func present() {
        guard delegate != nil else { return }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("UIImagePickerController.isSourceTypeAvailable(.camera) == false")
            return
        }
        
        hasCamearaAccess { [weak self] has in
            if has {
                self?.presentCameraPicker()
            } else {
                self?.pleaseGiveAccessInSettings(for: "camera")
            }
        }
    }
    
    private func presentCameraPicker() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    private func hasCamearaAccess(complition: @escaping(Bool) -> Void)  {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .authorized: complition(true)
            case .notDetermined: AVCaptureDevice.requestAccess(for: .video) { complition($0) }
            default: complition(false)
        }
    }
}
//MARK: UIImagePickerControllerDelegate
extension PhotoCameraPicker: UIImagePickerControllerDelegate {
    
    // Called when an image is captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            delegate?.picker(self, didSelect: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            delegate?.picker(self, didSelect: originalImage)
        } else {
            print("Image source not recognized")
        }
        
        picker.dismiss(animated: true)
    }
}

//MARK: UINavigationControllerDelegate
extension PhotoCameraPicker: UINavigationControllerDelegate { }

//MARK: - PhotoLibraryPicker
final class PhotoLibraryPicker: NSObject, PhotoPicker {
    
    weak var delegate: PhotoPickerDelegate?
    
    func present() {
        hasPhotoLibraryAccess { [weak self] has in
            if has {
                self?.presentPhotoLibraryPicker()
            } else {
                self?.pleaseGiveAccessInSettings(for: "photo library", typeAccess: "full ")
            }
        }
    }
    
    private func presentPhotoLibraryPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        delegate?.present(picker, animated: true)
    }
    
    private func hasPhotoLibraryAccess(complition: @escaping(Bool) -> Void)  {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
            case .authorized, .limited: complition(true)
            case .notDetermined: PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    complition(status == .authorized || status == .limited ? true : false)
                }
            }
            default: complition(false)
        }
    }
}

extension PhotoLibraryPicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first else {
            picker.dismiss(animated: true)
            return
        }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        picker.dismiss(animated: true)
                        return
                    }
                    
                    self.delegate?.picker(self, didSelect: image)
                    picker.dismiss(animated: true)
                }
            }
        }
    }
}
