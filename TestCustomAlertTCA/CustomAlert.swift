import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct CustomAlertReducer {
    
    @ObservableState
    struct State: Equatable {
        init(
            title: String,
            tapOnDimmingShouldClose: Bool = false
        ) {
            self.title = title
            self.tapOnDimmingShouldClose = tapOnDimmingShouldClose
        }
        
        let title: String
        let tapOnDimmingShouldClose: Bool
    }
    
    enum Action {
        case closeAlert
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeAlert:
                return .none
            }
        }
    }
}


struct CustomAlertView: View {
    
    var store: StoreOf<CustomAlertReducer>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                dimmingView()
                
                alertContainer()
                    .padding(.bottom)
            }
            .animation(.easeIn(duration: 0.3), value: store.title)
        }
    }
    
    @ViewBuilder
    private func dimmingView() -> some View {
        Color.black
            .opacity(0.30)
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
            .onTapGesture {
                if store.tapOnDimmingShouldClose {
                    store.send(.closeAlert)
                }
            }
    }
    
    @ViewBuilder
    private func alertContainer() -> some View {
        VStack(spacing: 40) {
            Text(store.title)
            
            Button("Close") {
                store.send(.closeAlert)
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 50)
        .padding(.vertical, 20)
        .background(Color.gray)
    }
}

#Preview {
    CustomAlertView(store: .init(
        initialState: .init(title: "Hello World"),
        reducer: { CustomAlertReducer() }
    ))
}


struct CustomAlertModifier: ViewModifier {
    
    var store: StoreOf<CustomAlertReducer>
    
    func body(content: Content) -> some View {
        WithPerceptionTracking {
            ZStack {
                content
                    .zIndex(0)
                
                CustomAlertView(store: store)
                    .zIndex(1)
            }
        }
    }
}

//extension View {
//    
//    func customAlert(_ item: Binding<StoreOf<CustomAlertReducer>?>) {
//        self.modifier(CustomAlertModifier(store: item))
//    }
//}
