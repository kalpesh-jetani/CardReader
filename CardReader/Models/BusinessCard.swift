import Foundation

struct PhoneContact: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var name: String = ""   // e.g. "Mobile", "Office", or a person's name
    var number: String = ""
}

struct BusinessCard: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var name: String = ""
    var jobTitle: String = ""
    var company: String = ""
    var email: String = ""
    var phoneContacts: [PhoneContact] = []
    var website: String = ""
    var address: String = ""
    var scannedAt: Date = Date()

    var isEmpty: Bool {
        [name, jobTitle, company, email, website, address].allSatisfy(\.isEmpty)
            && phoneContacts.isEmpty
    }

    var primaryPhone: String {
        phoneContacts.first?.number ?? ""
    }
}
