//
//  VideoPicker.swift
//  NYCFireWire
//
//  Created by Alex Rhodes on 1/20/21.
//  Copyright © 2021 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit

public protocol VideoPickerDelegate: class {
    func didSelect(url: URL?)
    func didSelect(image: UIImage?)
}


open class VideoPicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: VideoPickerDelegate?
    var snapshot: UIImage?

    public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.movie", "public.image"]
        self.pickerController.videoQuality = .typeMedium
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String, isVideo: Bool = false) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
            self.snapshot = isVideo ? UIImage(snapshotOf: pickerController.view) : nil
        }
    }
    
    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take video") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Video library", isVideo: true) {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerControllerImage(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
    
    private func pickerControllerURL(_ controller: UIImagePickerController, didSelect url: URL?) {
        controller.dismiss(animated: true, completion: nil)
        
            self.delegate?.didSelect(url: url)
    }
}

extension VideoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerControllerImage(picker, didSelect: nil)
        self.pickerControllerURL(picker, didSelect: nil)

    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        
        if let image = info[.editedImage] as? UIImage {
            self.pickerControllerImage(picker, didSelect: image)
            return
        }
        
        if let url = info[.mediaURL] as? URL {
            self.pickerControllerURL(picker, didSelect: url)
            return
        }

        self.pickerControllerImage(picker, didSelect: nil)
        self.pickerControllerURL(picker, didSelect: nil)

    }
}

extension VideoPicker: UINavigationControllerDelegate {
    
}

extension UIApplication {

    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return windows.first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }

    func makeSnapshot() -> UIImage? { return getKeyWindow()?.layer.makeSnapshot() }
}


extension CALayer {
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

extension UIView {
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
}

extension UIImage {
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
