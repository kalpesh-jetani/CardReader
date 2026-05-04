import SwiftUI
import PhotosUI

struct CardScannerView: View {
    var storage: CardStorageService
    @State private var viewModel = CardScannerViewModel()
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.scanState {
                case .idle:
                    idleView
                case .scanning:
                    scanningView
                case .reviewing:
                    reviewView
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle("Card Scanner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSaved = true
                    } label: {
                        Label("Saved", systemImage: "tray.full")
                    }
                    .badge(storage.cards.count)
                }
            }
            .navigationDestination(isPresented: $showSaved) {
                SavedCardsView(storage: storage)
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView { image in
                    showCamera = false
                    Task { await viewModel.processImage(image) }
                }
            }
            .onChange(of: photoPickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await viewModel.processImage(image)
                    }
                    photoPickerItem = nil
                }
            }
        }
    }

    // MARK: - Subviews

    private var idleView: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "creditcard.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                Text("Scan a Business Card")
                    .font(.title2.bold())
                Text("Use your camera or choose a photo\nto extract contact details instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: 12) {
                Button { showCamera = true } label: {
                    Label("Scan with Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Label("Choose from Photos", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    private var scanningView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView().scaleEffect(1.5)
            Text("Reading card…")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @ViewBuilder
    private var reviewView: some View {
        if let binding = cardBinding {
            NavigationStack {
                CardDetailView(card: binding, onSave: saveCard, onRescan: viewModel.reset)
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("Scan Failed").font(.title2.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") { viewModel.reset() }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private var cardBinding: Binding<BusinessCard>? {
        guard viewModel.scannedCard != nil else { return nil }
        return Binding(
            get: { viewModel.scannedCard ?? BusinessCard() },
            set: { viewModel.scannedCard = $0 }
        )
    }

    private func saveCard() {
        if let card = viewModel.scannedCard {
            storage.save(card)
        }
        viewModel.reset()
    }
}
