import Foundation

/// ViewModel Prototype
/// 解放遅延を起こさない。
/// メインスレッドは極力使用しない。
/// キャンセルに対応させる。
/// データ競合を起こさない。

final class ContentViewModel: ObservableObject {
    @Published private var asynchronousStateList: AsynchronousFunctionStateList = [
        .fetchData : .idle,
        .someFunction : .idle
    ]

    @Published private(set) var data: Data? = nil {
        didSet {
            guard data != nil else { return }
            asynchronousStateList[.fetchData] = .idle
        }
    }

    var isFetchingData: Bool {
        !(asynchronousStateList[.fetchData] == .idle)
    }

    deinit {
        print("Start deinit")
        asynchronousStateList.forEach {
            guard case .working(let task) = $0.value else { return }
            task.cancel()
        }
        print("Finish deinit")
    }

    func didTapFetchButton() {
        print("Tapped FetchButton")
        fetchData()
    }

    /// 明示的且つ故意的にTask.detachedとMainActor.runを弱参照にしていることに注意する。
    private func fetchData() {
        guard asynchronousStateList[.fetchData] == .idle else {
            print("現在fetchDataは実行されています。"); return;
        }

        asynchronousStateList[.fetchData] = .working(.detached { [weak self] in
            do {
                let url = URL(string: "https://picsum.photos/5000/5000")! // ⚠️ Forced unwrapping
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run { [weak self] in
                    self?.data = data
                }
            } catch {
                print("💥" + error.localizedDescription)
            }
        })
    }

    func didTapFetchCancelButton() {
        print("Tapped FetchCancelButton")
        fetchDataCancel()
    }

    private func fetchDataCancel() {
        guard case .working(let task) = asynchronousStateList[.fetchData] else {
            print("現在fetchDataは実行されていません。"); return;
        }
        task.cancel()
        asynchronousStateList[.fetchData] = .idle
    }
}
