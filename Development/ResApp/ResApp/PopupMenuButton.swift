import SwiftUI

struct PopupMenuButton: View {
    let title: String
    let options: [String]
    let color: Color
    let action: (String) -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Text(title)
                .font(.system(size: 28, weight: .semibold))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}

struct PopupMenuView: View {
    let title: String
    let options: [String]
    let action: (String) -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Text(title)
                    .font(.title2.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray6))
                
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                action(option)
                                isPresented = false
                            }) {
                                Text(option)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemGray6))
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 300)
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}
