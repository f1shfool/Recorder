import SwiftUI
import AVFoundation

struct FunctionalButtonView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @StateObject private var instructionSystem = CPRInstructionSystem()
    @StateObject private var elapsedTimeManager = ElapsedTimeManager()
    @State private var showSummary = false
    @State private var showEndConfirmation = false
    @State private var showPostCareAlert = false
    @State private var isROSCAchieved = false
    @State private var defibrillationCounter: Int = 0
    @State private var defibrillationTimer: Timer?
    @State private var selectedJoule: Int?
    @State private var showOtherMedicationsPopup = false
    @State private var showEventsPopup = false
    @Environment(\.presentationMode) var presentationMode

    // Add lists for medications and events
    private let otherMedications = [
        "Atropine",
        "Calcium",
        "D50",
        "Dopamine Infusion",
        "Lidocaine",
        "Magnesium",
        "NaHCO3",
        "Others"
    ]
    
    private let eventOptions = [
        "Intubation",
        "Termination of CPR",
        "Others"
    ]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side content
                VStack {
                    // Top row with timer, summary and end buttons
                    HStack {
                        Text("Timer: \(elapsedTimeManager.formattedTime)")
                            .font(.system(size: 44, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            showSummary.toggle()
                        }) {
                            Text("Summary")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .font(.system(size: 24, weight: .bold))
                        }
                        
                        Button(action: {
                            showEndConfirmation = true
                        }) {
                            Text("END")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .font(.system(size: 24, weight: .bold))
                        }
                    }
                    .padding(.bottom, 20)

                    // ECG Rhythm buttons
                    HStack(spacing: 10) {
                        FlashingButton(isFlashing: instructionSystem.shouldFlashECG) {
                            resuscitationManager.events.append(ResuscitationEvent(type: .ecgRhythm("VT/VF"), timestamp: Date()))
                            instructionSystem.handleRhythmInput(rhythm: "VT/VF")
                        } content: {
                            Text("pVT/VF")
                                .font(.system(size: 32, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        FlashingButton(isFlashing: false) {
                            resuscitationManager.events.append(ResuscitationEvent(type: .ecgRhythm("ROSC"), timestamp: Date()))
                            isROSCAchieved = true
                            showPostCareAlert = true
                        } content: {
                            Text("ROSC")
                                .font(.system(size: 36, weight: .bold))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        FlashingButton(isFlashing: instructionSystem.shouldFlashECG) {
                            resuscitationManager.events.append(ResuscitationEvent(type: .ecgRhythm("PEA/AS"), timestamp: Date()))
                            instructionSystem.handleRhythmInput(rhythm: "PEA/AS")
                        } content: {
                            Text("PEA/AS")
                                .font(.system(size: 32, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .frame(height: geometry.size.height * 0.18)
                    
                    Spacer().frame(height: 30)
                    
                    // Defibrillation Section
                    DefibrillationSection(
                        selectedJoule: $selectedJoule,
                        isFlashing: instructionSystem.shouldFlashDefibrillation,
                        onDefibrillate: { joule in
                            performDefibrillation(joule: joule)
                            instructionSystem.handleDefibrillation()
                        },
                        defibrillationCounter: defibrillationCounter
                    )
                    .disabled(isROSCAchieved)
                    
                    Spacer().frame(height: 30)
                    
                    // Medication buttons
                    VStack(spacing: 15) {
                        HStack(spacing: 10) {
                            FlashingButton(isFlashing: instructionSystem.shouldFlashAdrenaline) {
                                resuscitationManager.events.append(ResuscitationEvent(type: .medication("Adrenaline"), timestamp: Date()))
                                instructionSystem.shouldFlashAdrenaline = false
                            } content: {
                                Text("Adrenaline")
                                    .font(.system(size: 32, weight: .bold))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.green.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            
                            FlashingButton(isFlashing: instructionSystem.shouldFlashAmiodarone) {
                                resuscitationManager.events.append(ResuscitationEvent(type: .medication("Amiodarone"), timestamp: Date()))
                                instructionSystem.shouldFlashAmiodarone = false
                            } content: {
                                Text("Amiodarone")
                                    .font(.system(size: 32, weight: .bold))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.green.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                        .frame(height: geometry.size.height * 0.14)
                        
                        HStack(spacing: 10) {
                            // Other Medications Button
                            PopupMenuButton(
                                title: "Other Medications",
                                options: otherMedications,
                                color: Color.green,
                                action: { medication in
                                    resuscitationManager.events.append(
                                        ResuscitationEvent(type: .medication(medication), timestamp: Date())
                                    )
                                },
                                isPresented: $showOtherMedicationsPopup
                            )
                            
                            // Events Button
                            PopupMenuButton(
                                title: "Events",
                                options: eventOptions,
                                color: Color.green,
                                action: { event in
                                    resuscitationManager.events.append(
                                        ResuscitationEvent(type: .alert(event), timestamp: Date())
                                    )
                                },
                                isPresented: $showEventsPopup
                            )
                        }
                        .frame(height: geometry.size.height * 0.14)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
                .frame(width: geometry.size.width * 0.55)
                
                // Right side: Instructions
                InstructionView(instructionSystem: instructionSystem)
                    .frame(width: geometry.size.width * 0.45)
                    .background(Color(UIColor.systemGray6))
            }
            .sheet(isPresented: $showSummary) {
                ResuscitationSummaryView()
            }
            .alert("End Resuscitation?", isPresented: $showEndConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("End Resuscitation", role: .destructive) {
                    endResuscitation()
                }
            }
            .alert(isPresented: $showPostCareAlert) {
                Alert(
                    title: Text("ROSC Achieved"),
                    message: Text("Proceed to post-cardiac arrest care."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .fullScreenCover(isPresented: $showOtherMedicationsPopup) {
                PopupMenuView(
                    title: "Select Medication",
                    options: otherMedications,
                    action: { medication in
                        resuscitationManager.events.append(
                            ResuscitationEvent(type: .medication(medication), timestamp: Date())
                        )
                    },
                    isPresented: $showOtherMedicationsPopup
                )
                .background(BackgroundBlurView())
            }
            .fullScreenCover(isPresented: $showEventsPopup) {
                PopupMenuView(
                    title: "Select Event",
                    options: eventOptions,
                    action: { event in
                        resuscitationManager.events.append(
                            ResuscitationEvent(type: .alert(event), timestamp: Date())
                        )
                    },
                    isPresented: $showEventsPopup
                )
                .background(BackgroundBlurView())
            }
        }
        .onAppear {
            instructionSystem.reset()
            elapsedTimeManager.reset()
            elapsedTimeManager.start()
        }
        .onDisappear {
            instructionSystem.stopInstructions()
            stopDefibrillationCounter()
            elapsedTimeManager.stop()
        }
    }
    
    private func performDefibrillation(joule: Int) {
        resuscitationManager.events.append(ResuscitationEvent(type: .defibrillation(joule: joule), timestamp: Date()))
        startOrResetDefibrillationCounter()
    }
    
    private func startOrResetDefibrillationCounter() {
        defibrillationCounter = 0
        defibrillationTimer?.invalidate()
        defibrillationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            defibrillationCounter += 1
        }
    }
    
    private func stopDefibrillationCounter() {
        defibrillationTimer?.invalidate()
        defibrillationTimer = nil
    }
    
    private func endResuscitation() {
        instructionSystem.reset()
        stopDefibrillationCounter()
        elapsedTimeManager.stop()
        elapsedTimeManager.reset()
        resuscitationManager.endResuscitation()
    }
}

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
