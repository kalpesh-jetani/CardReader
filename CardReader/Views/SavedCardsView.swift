import SwiftUI

struct SavedCardsView: View {
    var storage: CardStorageService
    @State private var selectedCard: BusinessCard?

    var body: some View {
        Group {
            if storage.cards.isEmpty {
                emptyState
            } else {
                cardList
            }
        }
        .navigationTitle("Saved Cards")
        .navigationDestination(item: $selectedCard) { card in
            let binding = Binding(
                get: { storage.cards.first(where: { $0.id == card.id }) ?? card },
                set: { storage.save($0) }
            )
            CardDetailView(card: binding, onSave: { selectedCard = nil })
        }
    }

    private var cardList: some View {
        List {
            ForEach(storage.cards) { card in
                CardRowView(card: card)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedCard = card }
            }
            .onDelete { storage.delete(at: $0) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No saved cards")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Scanned cards will appear here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Card Row

struct CardRowView: View {
    let card: BusinessCard

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(.tint.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(initials)
                        .font(.headline)
                        .foregroundStyle(.tint)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name.isEmpty ? "Unknown" : card.name)
                    .font(.headline)

                if !card.jobTitle.isEmpty || !card.company.isEmpty {
                    Text([card.jobTitle, card.company].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let first = card.phoneContacts.first, !first.number.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone")
                            .font(.caption2)
                        Text(first.number)
                            .font(.caption)
                        if card.phoneContacts.count > 1 {
                            Text("+\(card.phoneContacts.count - 1) more")
                                .font(.caption)
                                .foregroundStyle(.tint)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        let words = card.name.split(separator: " ")
        let letters = words.prefix(2).compactMap(\.first).map(String.init)
        return letters.isEmpty ? "#" : letters.joined()
    }
}
