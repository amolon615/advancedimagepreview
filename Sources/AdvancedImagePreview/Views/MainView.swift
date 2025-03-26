//
//  File.swift
//  AdvancedImagePreview
//
//  Created by amolonus on 26/03/2025.
//

import SwiftUI

@main
struct MainView: App {
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
    
    var mainView: some View {
        ImageLoadingView(imageURL: MockImageModel.landscapeImage) {
            print("")
        }
    }
}

#Preview("Landscape preview") {
    ImageLoadingView(imageURL: MockImageModel.landscapeImage) {
        print("")
    }
}

#Preview("Portrait preview") {
    ImageLoadingView(imageURL: MockImageModel.portraitImage) {
        print("")
    }
}

