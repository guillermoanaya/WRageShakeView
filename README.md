# WRageShakeView

A description of this package.

## How to use it

``` swift
import WRageShakeView

struct ContentView: View {
  
  @State private var showRageShake = false
  @Published var report = RageShakeViewModel(report: .empty)
  
  var body: some View {
    Text("Hello, world!")
    .onShake {
      self.contentViewModel.createReport()
    }
    .fullScreenCover(isPresenting: showRageShake) {
      NavigationView {
        WRageShakeView(model: report)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                self.contentViewModel.cancelButtonTapped()
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Send") {
                self.contentViewModel.selfButtonTapped()
              }
            }
          }
      }
    }
  }
}
```
