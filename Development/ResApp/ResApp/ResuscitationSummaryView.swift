import SwiftUI

struct AddEventView: View {
    let record: ResuscitationRecord?
    @Binding var isPresented: Bool
    @ObservedObject var resuscitationManager: ResuscitationManager
    @State private var eventType = "Medication"
    @State private var eventDetails = ""
    @State private var eventDate = Date()
    @State private var selectedJoule: Int = 100
    
    let eventTypes = ["ECG Rhythm", "Medication", "Defibrillation", "Alert", "Others"]
    let jouleOptions = [100, 150, 200, 240]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Event Type", selection: $eventType) {
                    ForEach(eventTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                
                if eventType == "Defibrillation" {
                    Picker("Energy Level", selection: $selectedJoule) {
                        ForEach(jouleOptions, id: \.self) { joule in
                            Text("\(joule)J")
                        }
                    }
                } else {
                    TextField(getPlaceholderText(), text: $eventDetails)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                DatePicker("Time", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("Add Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    addEvent()
                    isPresented = false
                }
                .disabled(eventType != "Defibrillation" && eventDetails.isEmpty)
            )
        }
    }
    
    private func getPlaceholderText() -> String {
        switch eventType {
        case "ECG Rhythm":
            return "Enter rhythm (e.g., VF, PEA)"
        case "Medication":
            return "Enter medication name and dose"
        case "Others":
            return "Enter custom event details"
        default:
            return "Enter details"
        }
    }
    
    private func addEvent() {
        let event: ResuscitationEvent
        
        switch eventType {
        case "ECG Rhythm":
            event = ResuscitationEvent(type: .ecgRhythm(eventDetails), timestamp: eventDate)
        case "Medication":
            event = ResuscitationEvent(type: .medication(eventDetails), timestamp: eventDate)
        case "Defibrillation":
            event = ResuscitationEvent(type: .defibrillation(joule: selectedJoule), timestamp: eventDate)
        default:
            event = ResuscitationEvent(type: .alert(eventDetails), timestamp: eventDate)
        }
        
        if let record = record {
            resuscitationManager.addEvent(to: record, event: event)
        } else {
            resuscitationManager.events.append(event)
        }
    }
}

struct EventRow: View {
    let event: ResuscitationEvent
    let editMode: Bool
    let onDelete: (ResuscitationEvent) -> Void
    @State private var showEditSheet = false
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    var body: some View {
        HStack(spacing: 8) {
            if editMode {
                Button(action: {
                    onDelete(event)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .frame(width: 30)
            }
            
            Text(formatTime(event.timestamp))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            eventIcon(for: event)
                .frame(width: 30)
            
            if editMode {
                HStack {
                    Text(getEventDescription(event))
                        .lineLimit(1)
                    Spacer()
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            } else {
                Text(getEventDescription(event))
            }
        }
        .padding(.vertical, 2)
        .sheet(isPresented: $showEditSheet) {
            EditEventSheet(event: event, isPresented: $showEditSheet)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func eventIcon(for event: ResuscitationEvent) -> Image {
        switch event.type {
        case .ecgRhythm:
            return Image(systemName: "waveform.path.ecg")
        case .medication:
            return Image(systemName: "pill.fill")
        case .defibrillation:
            return Image(systemName: "bolt.heart.fill")
        case .alert:
            return Image(systemName: "exclamationmark.triangle.fill")
        }
    }
    
    private func getEventDescription(_ event: ResuscitationEvent) -> String {
        switch event.type {
        case .ecgRhythm(let rhythm):
            return "ECG Rhythm: \(rhythm)"
        case .medication(let medication):
            return "Medication: \(medication)"
        case .defibrillation(let joule):
            return "Defibrillation \(joule)J"
        case .alert(let message):
            return message
        }
    }
}

struct EditEventSheet: View {
    let event: ResuscitationEvent
    @Binding var isPresented: Bool
    @State private var editedText: String = ""
    @State private var selectedJoule: Int = 100
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    
    let jouleOptions = [100, 150, 200, 240]
    
    var body: some View {
        NavigationView {
            Form {
                if case .defibrillation = event.type {
                    Picker("Energy Level", selection: $selectedJoule) {
                        ForEach(jouleOptions, id: \.self) { joule in
                            Text("\(joule)J")
                        }
                    }
                } else {
                    Section {
                        TextField("Event Details", text: $editedText)
                    }
                }
            }
            .navigationBarTitle("Edit Event", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveChanges()
                    isPresented = false
                }
            )
            .onAppear {
                initializeEditValues()
            }
        }
    }
    
    private func initializeEditValues() {
        switch event.type {
        case .ecgRhythm(let rhythm):
            editedText = rhythm
        case .medication(let medication):
            editedText = medication
        case .defibrillation(let joule):
            selectedJoule = joule
        case .alert(let message):
            editedText = message
        }
    }
    
    private func saveChanges() {
        let newEvent: ResuscitationEvent
        
        switch event.type {
        case .ecgRhythm:
            newEvent = ResuscitationEvent(type: .ecgRhythm(editedText), timestamp: event.timestamp)
        case .medication:
            newEvent = ResuscitationEvent(type: .medication(editedText), timestamp: event.timestamp)
        case .defibrillation:
            newEvent = ResuscitationEvent(type: .defibrillation(joule: selectedJoule), timestamp: event.timestamp)
        case .alert:
            newEvent = ResuscitationEvent(type: .alert(editedText), timestamp: event.timestamp)
        }
        
        resuscitationManager.updateEvent(event: event, newEvent: newEvent)
    }
}

struct ResuscitationSummaryView: View {
    @EnvironmentObject var resuscitationManager: ResuscitationManager
    @State private var showClearConfirmation = false
    @State private var editMode = false
    @State private var showAddEventSheet = false
    @State private var selectedRecord: ResuscitationRecord?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Top Bar with Title, Edit, and Done buttons
                HStack {
                    Button(action: {
                        editMode.toggle()
                    }) {
                        Text(editMode ? "Done" : "Edit")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text("Resuscitation Records")
                        .font(.title.bold())
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                .padding()
                
                // Clear Records button
                if editMode {
                    Button(action: {
                        showClearConfirmation = true
                    }) {
                        Text("Clear Records")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    .padding(.bottom)
                }
                
                List {
                    if resuscitationManager.isResuscitationStarted {
                        Section(header: Text("CURRENT RESUSCITATION")) {
                            ForEach(resuscitationManager.events) { event in
                                EventRow(event: event, editMode: editMode) { event in
                                    if let index = resuscitationManager.events.firstIndex(where: { $0.id == event.id }) {
                                        resuscitationManager.events.remove(at: index)
                                    }
                                }
                            }
                            if editMode {
                                Button(action: {
                                    selectedRecord = nil
                                    showAddEventSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Event")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    ForEach(resuscitationManager.records) { record in
                        Section(header: Text("RESUSCITATION \(formatDate(record.startTime))")) {
                            ForEach(record.events) { event in
                                EventRow(event: event, editMode: editMode) { event in
                                    if let eventIndex = record.events.firstIndex(where: { $0.id == event.id }) {
                                        resuscitationManager.deleteEvents(at: IndexSet([eventIndex]), from: record)
                                    }
                                }
                            }
                            if editMode {
                                Button(action: {
                                    selectedRecord = record
                                    showAddEventSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Event")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView(record: selectedRecord,
                           isPresented: $showAddEventSheet,
                           resuscitationManager: resuscitationManager)
            }
            .alert("Clear All Records?", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    resuscitationManager.clearRecords()
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
