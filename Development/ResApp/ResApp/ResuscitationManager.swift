import SwiftUI

// Define ResuscitationRecord struct first
struct ResuscitationRecord: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let events: [ResuscitationEvent]
}

class ResuscitationManager: ObservableObject {
    @Published var isResuscitationStarted = false
    @Published var resuscitationStartTime: Date?
    @Published var events: [ResuscitationEvent] = []
    @AppStorage("resuscitationRecords") private var recordsData: Data = Data()
    @Published var records: [ResuscitationRecord] = []
    
    init() {
        loadRecords()
    }
    
    func startResuscitation() {
        isResuscitationStarted = true
        resuscitationStartTime = Date()
        events = []
    }
    
    func clearRecords() {
        records = []
        saveRecords()
    }
    
    func endResuscitation() {
        guard let startTime = resuscitationStartTime else { return }
        let currentEvents = events
        let record = ResuscitationRecord(
            id: UUID(),
            startTime: startTime,
            endTime: Date(),
            events: currentEvents
        )
        records.append(record)
        saveRecords()
        
        isResuscitationStarted = false
        resuscitationStartTime = nil
        events = []
    }
    
    func addEvent(to record: ResuscitationRecord, event: ResuscitationEvent) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            var updatedEvents = record.events
            updatedEvents.append(event)
            
            records[index] = ResuscitationRecord(
                id: record.id,
                startTime: record.startTime,
                endTime: record.endTime,
                events: updatedEvents
            )
            saveRecords()
        }
    }
    
    func deleteEvents(at indices: IndexSet, from record: ResuscitationRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            var updatedEvents = record.events
            indices.forEach { updatedEvents.remove(at: $0) }
            records[index] = ResuscitationRecord(
                id: record.id,
                startTime: record.startTime,
                endTime: record.endTime,
                events: updatedEvents
            )
            saveRecords()
        }
    }
    
    func updateEvent(event: ResuscitationEvent, newEvent: ResuscitationEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = newEvent
        }
        
        for (recordIndex, record) in records.enumerated() {
            if let eventIndex = record.events.firstIndex(where: { $0.id == event.id }) {
                var updatedEvents = record.events
                updatedEvents[eventIndex] = newEvent
                
                records[recordIndex] = ResuscitationRecord(
                    id: record.id,
                    startTime: record.startTime,
                    endTime: record.endTime,
                    events: updatedEvents
                )
                saveRecords()
                break
            }
        }
    }
    
    func deleteRecord(_ record: ResuscitationRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    private func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            recordsData = data
        } catch {
            print("Failed to save records: \(error)")
        }
    }
    
    private func loadRecords() {
        do {
            records = try JSONDecoder().decode([ResuscitationRecord].self, from: recordsData)
        } catch {
            records = []
        }
    }
}
