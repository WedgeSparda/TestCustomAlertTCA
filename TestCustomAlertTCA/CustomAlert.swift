import Foundation
import SwiftUI
import ComposableArchitecture

// MARK: - CustomAlertModel

public struct CustomAlertModel {
    
    public var title: String?
    public var message: String?
    public var buttons: [Button]
    public var bottomButton: Button?
    
    init(
        title: String? = nil,
        message: String? = nil,
        buttons: [Button],
        bottomButton: Button? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.bottomButton = bottomButton
    }
    
    public struct Button: Identifiable {
        public let id: UUID
        public let text: String
        public let action: () -> Void
        
        public init(
            text: String,
            action: @escaping () -> Void = {}
        ) {
            self.id = UUID()
            self.text = text
            self.action = action
        }
    }
}

// MARK: - CustomAlertState

public struct CustomAlertState<Action> {
    public var title: String?
    public var message: String?
    public var buttons: [Button]
    public var bottomButton: Button?
    
    public init(
        title: String? = nil,
        message: String? = nil,
        buttons: [Button],
        bottomButton: Button? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.bottomButton = bottomButton
    }
    
    public struct Button {
        public let text: String
        public let action: CustomAlertAction?
        
        public init(
            text: String,
            action: CustomAlertAction? = nil
        ) {
            self.text = text
            self.action = action
        }
    }
    
    public struct CustomAlertAction {
        public let action: Action
        fileprivate let animation: Animation
        
        fileprivate enum Animation: Equatable {
            case inherited
            case explicit(SwiftUI.Animation?)
        }
        
        public init(
            action: Action,
            animation: SwiftUI.Animation?
        ) {
            self.action = action
            self.animation = .explicit(animation)
        }
        
        public init(action: Action) {
            self.action = action
            self.animation = .inherited
        }
    }
}

extension CustomAlertState.Button {
    fileprivate func converted(
        send: @escaping (Action) -> Void,
        sendWithAnimation: @escaping (Action, Animation?) -> Void
    ) -> CustomAlertModel.Button {
        .init(text: self.text) {
            if let action = self.action {
                switch action.animation {
                case .inherited:
                    send(action.action)
                case let .explicit(animation):
                    sendWithAnimation(action.action, animation)
                }
            }
        }
    }
}

extension CustomAlertState {
    fileprivate func converted(
        send: @escaping (Action) -> Void,
        sendWithAnimation: @escaping (Action, Animation?) -> Void
    ) -> CustomAlertModel {
        .init(
            title: self.title,
            message: self.message,
            buttons: self.buttons.map { $0.converted(send: send, sendWithAnimation: sendWithAnimation) },
            bottomButton: self.bottomButton.map { $0.converted(send: send, sendWithAnimation: sendWithAnimation)}
        )
    }
}

extension CustomAlertState: Equatable where Action: Equatable {}
extension CustomAlertState.Button: Equatable where Action: Equatable {}
extension CustomAlertState.CustomAlertAction: Equatable where Action: Equatable {}
extension CustomAlertState: _EphemeralState {
    public static var actionType: Any.Type { Action.self }
}

// MARK: - View Extensions

extension View {
    func customAlert<AlertAction: Equatable>(
        _ item: Binding<Store<CustomAlertState<AlertAction>, AlertAction>?>
    ) -> some View {
        let store = item.wrappedValue
        let state = store?.withState { $0 }
        return self.customAlert(
            item: Binding(
                get: {
                    state?.converted(
                        send: { store?.send($0) },
                        sendWithAnimation: { store?.send($0, animation: $1)})
                },
                set: {
                    if $0 == nil {
                        item.transaction($1).wrappedValue = nil
                    }
                }
            )
        )
    }
    
    func customAlert(item: Binding<CustomAlertModel?>) -> some View {
        self.modifier(CustomAlertModifier(item: item))
    }
}

// MARK: - CustomAlertModifier

public struct CustomAlertModifier: ViewModifier {
    
    @Binding var item: CustomAlertModel?
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if self.item != nil {
                    Rectangle()
                        .fill(Color.black.opacity(0.30))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                self.item = nil
                            }
                        }
                        .transition(.opacity.animation(.default))
                        .ignoresSafeArea()
                }
            }
            .overlay(alignment: .bottom) {
                if let alert = self.item {
                    VStack(spacing: 20) {
                        if let title = alert.title {
                            Text(title)
                                .foregroundStyle(.green)
                            
                        }
                        
                        if let message = alert.message {
                            Text(message)
                                .foregroundStyle(.black)
                        }
                        
                        VStack(spacing: 24) {
                            ForEach(alert.buttons) { button in
                                Button(action: button.action) {
                                    Text(button.text)
                                }
                            }
                        }
                        
                        if let bottomButton = alert.bottomButton {
                            Button(action: bottomButton.action) {
                                Text(bottomButton.text)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.white)
                    .transition(.move(edge: .bottom).animation(.default))
                }
            }
    }
}
