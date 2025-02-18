import SwiftUI

struct DefibrillationSection: View {
    @Binding var selectedJoule: Int?
    let isFlashing: Bool
    let onDefibrillate: (Int) -> Void
    let defibrillationCounter: Int
    
    // Available joule options
    let jouleOptions = [100, 150, 200, 240]
    
    var formattedDefibrillationTime: String {
        let minutes = defibrillationCounter / 60
        let seconds = defibrillationCounter % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Main Defibrillation Button
            FlashingButton(isFlashing: isFlashing) {
                if let joule = selectedJoule {
                    onDefibrillate(joule)
                }
            } content: {
                HStack {
                    Text(formattedDefibrillationTime)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("Defibrillation")
                    if let selectedJoule = selectedJoule {
                        Text("\(selectedJoule)J")
                            .font(.system(size: 24, weight: .bold))
                    }
                    Spacer()
                    Image(systemName: "bolt.heart.fill")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    selectedJoule == nil ? Color.gray : Color.red
                )
                .foregroundColor(.white)
                .cornerRadius(15)
                .font(.system(size: 36, weight: .bold))
            }
            .disabled(selectedJoule == nil)
            
            // Joule Selection Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(jouleOptions, id: \.self) { joule in
                    Button(action: {
                        selectedJoule = joule
                    }) {
                        Text("\(joule)J")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                joule == selectedJoule ?
                                Color.red : // Currently selected joule
                                Color(red: 1.0, green: 0.6, blue: 0.6) // Light red for unselected
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
