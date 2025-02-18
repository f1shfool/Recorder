import SwiftUI

class ElapsedTimeManager: ObservableObject {
    @Published var elapsedSeconds: Int = 0
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        elapsedSeconds = 0
    }
    
    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
