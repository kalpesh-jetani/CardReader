import SwiftUI
import Vision

@Observable
@MainActor
final class CardScannerViewModel {

    enum ScanState {
        case idle, scanning, reviewing, error(String)
    }

    var scanState: ScanState = .idle
    var scannedCard: BusinessCard?
    var capturedImage: UIImage?

    private let parser = CardTextParser()

    func processImage(_ image: UIImage) async {
        scanState = .scanning
        capturedImage = image

        guard let cgImage = image.cgImage else {
            scanState = .error("Could not process image.")
            return
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            let observations = request.results ?? []
            let lines = observations
                .compactMap { $0.topCandidates(1).first?.string }
            let card = parser.parse(lines: lines)
            scannedCard = card
            scanState = .reviewing
        } catch {
            scanState = .error(error.localizedDescription)
        }
    }

    func reset() {
        scanState = .idle
        scannedCard = nil
        capturedImage = nil
    }
}
