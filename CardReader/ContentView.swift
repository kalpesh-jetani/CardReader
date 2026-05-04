//
//  ContentView.swift
//  CardReader
//
//  Created by Kalpesh on 04/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var storage = CardStorageService()

    var body: some View {
        CardScannerView(storage: storage)
    }
}

#Preview {
    ContentView()
}
