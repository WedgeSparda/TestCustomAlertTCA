import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct MainReducer {
    
    @ObservableState
    struct State {
        @Presents var customAlert: CustomAlertReducer.State?
    }
    
    enum Action {
        case buttonTapped(Bool)
        case customAlert(CustomAlertReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case let .buttonTapped(tapOnDimmingShouldClose):
                guard state.customAlert == nil else {
                    return .none
                }
                state.customAlert = .init(
                    title: "This is a custom alert",
                    tapOnDimmingShouldClose: tapOnDimmingShouldClose
                )
                return .none
                
            case .customAlert(.closeAlert):
                state.customAlert = nil
                return .none
                
            case .customAlert:
                return .none
            }
        }
        .ifLet(\.customAlert, action: \.customAlert) {
            CustomAlertReducer()
        }
    }
}

struct MainView: View {
    
    @Perception.Bindable var store: StoreOf<MainReducer>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack {
                    Button("Show alert") {
                        store.send(.buttonTapped(false))
                    }
                    
                    Button("Show alert with Diming Close") {
                        store.send(.buttonTapped(true))
                    }
                }
                
                if let store = store.scope(state: \.customAlert, action: \.customAlert) {
                    CustomAlertView(store: store)
                }
            }
        }
    }
}


#Preview {
    MainView(store: .init(
        initialState: .init(),
        reducer: { MainReducer() }
    ))
}
