import SwiftUI

struct CardDetailView: View {
    @Binding var card: BusinessCard
    var onSave: () -> Void
    var onRescan: (() -> Void)?

    var body: some View {
        Form {
            personalSection
            phoneSection
            contactSection
            businessSection
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onRescan {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Re-scan", action: onRescan)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: onSave)
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Sections

    private var personalSection: some View {
        Section("Person") {
            LabeledTextField(label: "Name", icon: "person", text: $card.name)
            LabeledTextField(label: "Title", icon: "briefcase", text: $card.jobTitle)
        }
    }

    private var phoneSection: some View {
        Section {
            ForEach($card.phoneContacts) { $contact in
                PhoneContactRow(contact: $contact)
            }
            .onDelete { card.phoneContacts.remove(atOffsets: $0) }

            Button {
                card.phoneContacts.append(PhoneContact(name: "", number: ""))
            } label: {
                Label("Add Phone", systemImage: "plus.circle")
            }
        } header: {
            Text("Phone Numbers")
        }
    }

    private var contactSection: some View {
        Section("Contact") {
            LabeledTextField(label: "Email", icon: "envelope", text: $card.email)
            LabeledTextField(label: "Website", icon: "globe", text: $card.website)
        }
    }

    private var businessSection: some View {
        Section("Business") {
            LabeledTextField(label: "Company", icon: "building.2", text: $card.company)
            LabeledTextField(label: "Address", icon: "mappin.and.ellipse", text: $card.address)
        }
    }
}

// MARK: - Phone Contact Row

private struct PhoneContactRow: View {
    @Binding var contact: PhoneContact

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                TextField("Contact name (optional)", text: $contact.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Image(systemName: "phone")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                TextField("Phone number", text: $contact.number)
                    .keyboardType(.phonePad)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Labeled Text Field

private struct LabeledTextField: View {
    let label: String
    let icon: String
    @Binding var text: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
                .frame(minWidth: 90, alignment: .leading)
            TextField(label, text: $text)
                .multilineTextAlignment(.trailing)
        }
    }
}
