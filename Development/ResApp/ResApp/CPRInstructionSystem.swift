import SwiftUI

class CPRInstructionSystem: ObservableObject {
    @Published var currentInstruction: String = "Check pulse & rhythm"
    @Published var timeRemaining: Int = 120
    @Published var cycleCount: Int = 1
    @Published var isWaitingForInput: Bool = true
    @Published var shouldFlashDefibrillation = false
    @Published var shouldFlashECG = false
    @Published var shouldFlashAdrenaline = false
    @Published var shouldFlashAmiodarone = false
    
    private var timer: Timer?
    
    private let medicationSchedule = [
        2: ["Adrenaline"],
        4: ["Adrenaline", "Amiodarone 300mg"],
        6: ["Adrenaline", "Amiodarone 150mg"],
        8: ["Adrenaline"]
    ]
    
    func handleRhythmInput(rhythm: String) {
        shouldFlashECG = false
        isWaitingForInput = false
        if rhythm == "VT/VF" {
            currentInstruction = "Perform Defibrillation"
            shouldFlashDefibrillation = true
        } else {
            startCPRWithMedication()
        }
    }
    
    func handleDefibrillation() {
        shouldFlashDefibrillation = false
        startCPRWithMedication()
    }
    
    private func startCPRWithMedication() {
        if let medications = medicationSchedule[cycleCount] {
            currentInstruction = "Start CPR and administer \(medications.joined(separator: " + "))"
            shouldFlashAdrenaline = medications.contains("Adrenaline")
            shouldFlashAmiodarone = medications.contains { $0.contains("Amiodarone") }
        } else {
            currentInstruction = "Start CPR"
        }
        startTimer()
    }
    
    private func startTimer() {
        timeRemaining = 120
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.cycleCount += 1
                self.currentInstruction = "Check pulse & rhythm"
                self.isWaitingForInput = true
                self.shouldFlashECG = true
            }
        }
    }
    
    func reset() {
            stopInstructions()
            currentInstruction = "Check pulse & rhythm"
            isWaitingForInput = true
            timeRemaining = 120
            cycleCount = 1
            shouldFlashDefibrillation = false
            shouldFlashECG = true  // Set to true on reset
            shouldFlashAdrenaline = false
            shouldFlashAmiodarone = false
        }
        
        init() {
            shouldFlashECG = true  // Add this line to initialize with blinking
        }
    
    func stopInstructions() {
        timer?.invalidate()
        timer = nil
    }
}

struct InstructionView: View {
    @ObservedObject var instructionSystem: CPRInstructionSystem
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Cycle \(instructionSystem.cycleCount)")
                .font(.system(size: 48, weight: .bold))
            
            if !instructionSystem.isWaitingForInput {
                Text("\(instructionSystem.timeRemaining / 60):\(String(format: "%02d", instructionSystem.timeRemaining % 60))")
                    .font(.system(size: 72, weight: .bold))
                    .monospacedDigit()
            }
            
            Text(instructionSystem.currentInstruction)
                .font(.system(size: 36))
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(40)
    }
}

