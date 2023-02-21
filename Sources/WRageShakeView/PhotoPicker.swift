//
//  PhotoPicker.swift
//  WRageShake
//
//  Created by Guillermo Anaya on 15/02/23.
//

import SwiftUI
import PhotosUI

public struct RageShakePickerConfig {
  public let library: PHPhotoLibrary
  /// Maximum number of assets that can be selected. Default is 1.
  ///
  /// Setting `selectionLimit` to 0 means maximum supported by the system.
  public var selectionLimit: Int

  /// Applying a filter to restrict the types that can be displayed. Default is `nil`.
  ///
  /// Setting `filter` to `nil` means all asset types can be displayed.
  public var filter: PHPickerFilter?
  
  static public let defaultConfig = RageShakePickerConfig(library: .shared(), selectionLimit: 0, filter: .images)
}

struct PhotoPicker: UIViewControllerRepresentable {
  
  var pickerConfig: RageShakePickerConfig
  var onComplete: ([PickerImageResult]) -> Void
  
  func makeUIViewController(context: Context) -> some UIViewController {
    var configuration = PHPickerConfiguration(photoLibrary: pickerConfig.library)
    configuration.filter = pickerConfig.filter
    configuration.selectionLimit = pickerConfig.selectionLimit
    
    let photoPickerViewController = PHPickerViewController(configuration: configuration)
    photoPickerViewController.delegate = context.coordinator
    return photoPickerViewController
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: PHPickerViewControllerDelegate {
    private let parent: PhotoPicker
    
    init(_ parent: PhotoPicker) {
      self.parent = parent
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage? {
      let scale = newHeight / image.size.height
      let newWidth = image.size.width * scale
      UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
      image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return newImage
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      if results.isEmpty {
        self.parent.onComplete([])
        return
      }
      
      var result = [PickerImageResult]()
      let count = results.count
      for (i, image) in results.enumerated() {
        if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
          image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, error in
            if let error = error {
              print("Can't load image \(error.localizedDescription)")
            } else if let image = newImage as? UIImage, let thumbnail = self?.resizeImage(image: image, newHeight: 100) {
              result.append(PickerImageResult(thumbnail: thumbnail, fullsize: image))
              if i == count - 1 {
                DispatchQueue.main.async {
                  self?.parent.onComplete(result)
                }
              }
            }
          }
        }
      }
    }
  }
}
