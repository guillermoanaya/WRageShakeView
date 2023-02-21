import SwiftUI
import UIKit.UIImage
import SwiftUINavigation

public struct RageShakeReport: Identifiable {
  public var reportDescription: String
  public var pickerResult: [PickerImageResult]
  public let id: UUID
  
  static public let empty = RageShakeReport(reportDescription: "", pickerResult: [], id: UUID())
}

public struct PickerImageResult: Identifiable {
  public let id = UUID()
  public let thumbnail: UIImage
  public let fullsize: UIImage
}

final public class RageShakeViewModel: Identifiable, ObservableObject {
  
  @Published public var destination: Destination?
  
  @Published public var report: RageShakeReport
  
  var pickerConfig: RageShakePickerConfig
  
  public enum Destination: Equatable {
    case imagePicker
    case fullscreen(UIImage)
  }
  
  public init(report: RageShakeReport, destination: Destination? = nil, config: RageShakePickerConfig = .defaultConfig) {
    self.report = report
    self.pickerConfig = config
    self.destination = destination
  }
  
  func uploadImageTapped() {
    self.destination = .imagePicker
  }
  
  func onImagePicked(_ images: [PickerImageResult]) {
    self.report.pickerResult = images
    self.destination = nil
  }
  
  func onSelectImage(_ image: UIImage) {
    self.destination = .fullscreen(image)
  }
  
  func onImageSelectedCloseButton() {
    self.destination = nil
  }
}

public struct WRageShakeView: View {
  @ObservedObject var model: RageShakeViewModel

  public var body: some View {
    VStack {
      Text("Describe the problem")
        .foregroundColor(.black)
      TextEditor(text: self.$model.report.reportDescription)
        .foregroundColor(.gray)
      ScrollView(.horizontal) {
        HStack {
          ForEach(self.model.report.pickerResult, id: \.id) { imageResult in
            ImageWithDelete(uimage: imageResult.thumbnail) {
              
            }.onTapGesture {
              self.model.onSelectImage(imageResult.fullsize)
            }
          }
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button {
            self.model.uploadImageTapped()
          } label: {
            Image(systemName: "photo")
              .font(.headline)
              .foregroundColor(.accentColor)
          }
          Spacer()
        } // ToolbarItemGroup
      }
    }
    .sheet(unwrapping: self.$model.destination, case: /RageShakeViewModel.Destination.imagePicker) { _ in
      PhotoPicker(pickerConfig: self.model.pickerConfig) { images in
        self.model.onImagePicked(images)
      }
    }
    .fullScreenCover(unwrapping: self.$model.destination, case: /RageShakeViewModel.Destination.fullscreen) { $image in
      NavigationView {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .edgesIgnoringSafeArea(.top)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              self.model.onImageSelectedCloseButton()
            }
          }
        }
      }
    }
  }
}
