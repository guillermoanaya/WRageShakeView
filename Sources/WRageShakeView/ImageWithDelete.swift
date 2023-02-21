//
//  File.swift
//  
//
//  Created by Guillermo Anaya on 20/02/23.
//

import SwiftUI

struct ImageWithDelete: View {
  
  let uimage: UIImage
  let closeButtonTapped: () -> Void
  let context: [String: Any]?
  
  init(uimage: UIImage, _ context:[String: Any]? = nil, _ onTapped: @escaping () -> Void) {
    self.uimage = uimage
    self.closeButtonTapped = onTapped
    self.context = context
  }
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      Image.init(uiImage: uimage)
      Button(action: {
        closeButtonTapped()
      }) {
        Image(systemName: "xmark.circle")
      }
      .background(.black)
    }
  }
}
