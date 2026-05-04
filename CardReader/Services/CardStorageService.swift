import Foundation
import SwiftUI

@Observable
@MainActor
final class CardStorageService {

    private(set) var cards: [BusinessCard] = []

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("saved_cards.json")
    }()

    init() {
        load()
    }

    func save(_ card: BusinessCard) {
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards[idx] = card
        } else {
            cards.insert(card, at: 0)
        }
        persist()
    }

    func delete(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ card: BusinessCard) {
        cards.removeAll { $0.id == card.id }
        persist()
    }

    // MARK: - Private

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        cards = (try? JSONDecoder().decode([BusinessCard].self, from: data)) ?? []
    }

    private func persist() {
        let data = try? JSONEncoder().encode(cards)
        try? data?.write(to: fileURL, options: .atomic)
    }
}
