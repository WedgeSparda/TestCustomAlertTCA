import SwiftUI
import ComposableArchitecture

@main
struct TestCustomAlertTCAApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(store: .init(initialState: .init(), reducer: {
                MainReducer()
            }))
        }
    }
}
