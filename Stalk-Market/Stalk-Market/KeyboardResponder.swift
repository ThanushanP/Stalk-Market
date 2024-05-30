//
//  KeyboardResponder.swift
//  Stalk-Market
//
//  Created by Thanushan Pirapakaran on 2024-05-28.
//

import Foundation
import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { rect in
                rect.origin.y >= UIScreen.main.bounds.height ? 0 : rect.height
            }
            .assign(to: \.currentHeight, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
