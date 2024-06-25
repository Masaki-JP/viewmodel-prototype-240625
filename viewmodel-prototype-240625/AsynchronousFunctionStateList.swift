import Foundation

typealias AsynchronousFunctionStateList = [AsynchronousFunction : AsynchronousFunctionState]

enum AsynchronousFunction: Hashable {
    case fetchData, someFunction
}

enum AsynchronousFunctionState: Equatable {
    case working(Task<Void, Never>)
    case idle
}
