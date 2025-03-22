//
//  File.swift
//  AdvancedImagePreview
//
//  Created by amolonus on 26/03/2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ImageLoadingView(imageURL: URL(string: "https://apple.com")!) {
            print("")
        }
    }
}
