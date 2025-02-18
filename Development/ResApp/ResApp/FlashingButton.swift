import SwiftUI

struct FlashingButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    let isFlashing: Bool
    
    @State private var opacity: Double = 1.0
    
    init(isFlashing: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
        self.isFlashing = isFlashing
    }
    
    var body: some View {
        Button(action: action) {
            content
                .opacity(opacity)
        }
        .onAppear {
            if isFlashing {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                    opacity = 0.3
                }
            }
        }
        .onChange(of: isFlashing) { _, newValue in
            if newValue {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                    opacity = 0.3
                }
            } else {
                withAnimation {
                    opacity = 1.0
                }
            }
        }
    }
}

