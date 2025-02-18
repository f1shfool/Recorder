import Foundation

struct ResuscitationEvent: Codable, Identifiable {
    let id = UUID()
    enum EventType: Codable {
        case ecgRhythm(String)
        case medication(String)
        case defibrillation(joule: Int)
        case alert(String)
    }
    
    let type: EventType
    let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case type, timestamp
    }
}
