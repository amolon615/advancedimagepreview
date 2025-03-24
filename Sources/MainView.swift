//
//  File.swift
//  AdvancedImagePreview
//
//  Created by amolonus on 26/03/2025.
//

import SwiftUI

@main
struct MainView: View {
    var body: some View {
        ImageLoadingView(imageURL: MockImageModel.landscapeImage) {
            print("")
        }
    }
}
