//
//  ImageLoadingView.swift
//  AdvancedImagePreview
//
//  Created by amolonus on 26/03/2025.
//
import SwiftUI

struct ImageLoadingView: View {
    let imageURL: URL
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadError = false
    @State private var viewID = UUID()
    
    var onDismiss: (() -> Void)?
    
    func loadImageFromURL(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.loadError = true
                    self.isLoading = false
                }
                completion(nil)
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.loadError = true
                    self.isLoading = false
                    completion(nil)
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if loadError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Failed to load image")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            } else if let image = image {
                ZoomImageView(image: image)
                    .onDragEnd { drag in
                        onDismiss?()
                    }
            }
            
            // Close button in the top corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing], 16)
                }
                Spacer()
            }
        }
        .onAppear {
            // Generate a new ID to force view recreation
            viewID = UUID()
            isLoading = true
            loadImageFromURL(url: imageURL) { loadedImage in
                self.image = loadedImage
            }
        }
        .onDisappear {
            // Reset the image to force a clean state next time
            self.image = nil
        }
    }
}
