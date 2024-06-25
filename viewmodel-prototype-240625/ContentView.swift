import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            if let data = viewModel.data {
                Image(uiImage: .init(data: data)!) // ⚠️ Forced unwrapping
                    .resizable()
                    .scaledToFit()
            } else {
                Text("ViewModel doesn't have data.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if viewModel.isFetchingData == true {
                Color.black.opacity(0.1).ignoresSafeArea()
                ProgressView()
            }
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 30) {
                Button("Fetch") {
                    viewModel.didTapFetchButton()
                }
                .disabled(viewModel.isFetchingData == true)

                Button("Cancel") {
                    viewModel.didTapFetchCancelButton()
                }
                .disabled(viewModel.isFetchingData == false)
            }
        }
    }
}

#Preview {
    ContentView()
}
