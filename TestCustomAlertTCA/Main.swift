import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct MainReducer {
    
    @Reducer(state: .equatable)
    public enum Destination {
        @ReducerCaseEphemeral
        case customAlert(CustomAlertState<CustomAlert>)
        
        @CasePathable
        public enum CustomAlert: Equatable {
            case action1
            case action2
            case action3
            case bottomAction
        }
    }
    
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case showAlertButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .showAlertButtonTapped:
                state.destination = .customAlert(
                    .init(
                        title: "This is a title",
                        message: "This is a message",
                        buttons: [
                            .init(text: "Action 1", action: .init(action: .action1, animation: .default)),
                            .init(text: "Action 2", action: .init(action: .action2, animation: .default)),
                            .init(text: "Action 3", action: .init(action: .action3, animation: .default))
                        ],
                        bottomButton: .init(text: "Bottom Action", action: .init(action: .bottomAction, animation: .default))
                    )
                )
                return .none
                             
            case .destination(.presented(.customAlert(.action1))):
                print("ACTION 1")
                return .none
                
            case .destination(.presented(.customAlert(.action2))):
                print("ACTION 2")
                return .none
                
            case .destination(.presented(.customAlert(.action3))):
                print("ACTION 3")
                return .none
                
            case .destination(.presented(.customAlert(.bottomAction))):
                print("BOTTOM ACTION")
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct MainView: View {
    
    @Perception.Bindable var store: StoreOf<MainReducer>
    
    var body: some View {
        WithPerceptionTracking {
            Button("Show alert") { store.send(.showAlertButtonTapped, animation: .default) }
            .customAlert($store.scope(state: \.destination?.customAlert, action: \.destination.customAlert))
        }
    }
}


#Preview {
    MainView(store: .init(
        initialState: .init(),
        reducer: { MainReducer() }
    ))
}
