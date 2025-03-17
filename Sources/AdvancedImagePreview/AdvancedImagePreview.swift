// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 17.0, *)
public struct VerticalPanningView: View {
    public let imageName: String
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    private let maxOverpan: CGFloat = 20
    
    @State private var containerSize: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    @State private var magnificationNotInProgress: Bool = false
    @State private var isZoomed: Bool = false
    @State private var showContextMenu: Bool = false
    
    
    @State private var currentScale: CGFloat = 1
    
    @Namespace private var animation
    
    public var body: some View {
        GeometryReader { outerGeo in
            ZStack {
                Color.clear
                    .onAppear {
                        containerSize = outerGeo.size
                    }
                    .onChange(of: outerGeo.size) { oldValue, newValue in
                        containerSize = newValue
                    }
                
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(currentScale, anchor: calculateTapPoint())
                //                    .conditionalScaleType($isZoomed, namespace: animation)
                    .background(
                        GeometryReader { imageGeo -> Color in
                            DispatchQueue.main.async {
                                imageSize = imageGeo.size
                            }
                            return Color.clear
                        }
                    )
                    .coordinateSpace(.named("imageSpace"))
                    .offset(x: offset.width)
                    .ignoresSafeArea()
                    .overlay {
                        if isZoomed && showContextMenu {
                            VStack {
                                HStack {
                                    Button {} label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Color.white)
                                            .bold()
                                            .padding(7)
                                            .background {
                                                Circle()
                                                    .foregroundStyle(Color.black.opacity(0.6))
                                            }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                    .padding(.top, 20)
                                }
                                .frame(height: 100)
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            .frame(height: 100)
                            .background {
                                ZStack {
                                    LinearGradient(colors: [.black.opacity(0.4), .black.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom)
                                    TransparentBlurView(removeAllFilters: true)
                                        .blur(radius: 5, opaque: false)
                                        .visualEffect { view, proxy in
                                            view
                                                .offset(y: (proxy.bounds(of: .scrollView)?.minY ?? 0))
                                        }
                                        .zIndex(1000)
                                }
                            }
                            .offset(y: -3)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .ignoresSafeArea(.all, edges: .top)
                        }
                    }
                    .onTapGesture {
                        guard isZoomed else { return }
                        withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0.25)) {
                            showContextMenu.toggle()
                        }
                    }
                    .gesture(
                        SpatialTapGesture(count: 2, coordinateSpace: .global)
                            .onEnded({ value in
                                withAnimation {
                                    currentScale = 1.2
                                }
                                //                                if isZoomed {
                                //                                    withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0.1)) {
                                //                                        isZoomed = false
                                //                                        offset = .zero
                                //                                        lastOffset = .zero // Reset lastOffset
                                //                                        showContextMenu = false
                                //                                    }
                                //                                } else {
                                //                                    magnificationNotInProgress = true
                                //                                    withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0.25)) {
                                //                                        isZoomed = true
                                //                                        offset = .zero // Ensure offset is reset
                                //                                        lastOffset = .zero // Reset lastOffset
                                //                                    }
                                //                                }
                            })
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard isZoomed else { return }
                                isDragging = true
                                
                                // Calculate the displayed image size based on aspect ratio
                                let displayedImageSize = calculateDisplayedImageSize()
                                
                                // Determine if we're dealing with a portrait or landscape image
                                let isPortraitImage = displayedImageSize.height > displayedImageSize.width
                                
                                // Calculate the maximum pan width (how far the image can be panned)
                                let maxPanWidth = max(0, displayedImageSize.width - containerSize.width)
                                
                                // For portrait images, the maxPanWidth might be very small or zero
                                // We need to adjust the overpan behavior accordingly
                                let effectiveMaxOverpan = isPortraitImage ? min(maxOverpan, containerSize.width * 0.1) : maxOverpan
                                
                                // Calculate raw potential offset
                                let rawPotentialOffset = lastOffset.width + value.translation.width
                                
                                // Apply different logic for each side
                                let clampedOffset: CGFloat
                                
                                if rawPotentialOffset > 0 {
                                    // Right overpan (beyond left edge of image)
                                    // Apply resistance - the further you drag, the harder it gets
                                    let overpanFactor = 0.2 // Lower = more resistance
                                    clampedOffset = rawPotentialOffset * overpanFactor
                                    print("RIGHT OVERPAN: \(clampedOffset)")
                                } else if rawPotentialOffset < -maxPanWidth {
                                    // Left overpan (beyond right edge of image)
                                    // Apply resistance - the further you drag, the harder it gets
                                    let overpanAmount = abs(rawPotentialOffset) - maxPanWidth
                                    let resistedAmount = overpanAmount * 0.2 // Same resistance factor
                                    clampedOffset = -maxPanWidth - resistedAmount
                                    print("LEFT OVERPAN: \(clampedOffset)")
                                } else {
                                    // Within normal panning range
                                    clampedOffset = rawPotentialOffset
                                    print("NORMAL PAN: \(clampedOffset)")
                                }
                                
                                // Print debug info
                                print("Raw: \(rawPotentialOffset), Clamped: \(clampedOffset), MaxPanWidth: \(maxPanWidth)")
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0.25)) {
                                    offset = CGSize(width: clampedOffset, height: 0)
                                }
                            }
                        
                            .onEnded { value in
                                guard isZoomed else { return }
                                isDragging = false
                                
                                let displayedImageSize = calculateDisplayedImageSize()
                                let maxPanWidth = max(0, displayedImageSize.width - containerSize.width)
                                
                                // Snap back if we're in the overpan area
                                let finalOffset: CGFloat
                                if offset.width > 0 {
                                    // Overpanned beyond left edge - snap back to left edge (0)
                                    finalOffset = 0
                                } else if offset.width < -maxPanWidth {
                                    // Overpanned beyond right edge - snap back to right edge (-maxPanWidth)
                                    finalOffset = -maxPanWidth
                                } else {
                                    // Within normal panning range
                                    finalOffset = offset.width
                                }
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0.25)) {
                                    offset = CGSize(width: finalOffset, height: 0)
                                }
                                
                                lastOffset = offset
                            }
                        
                    )
                
            }
        }
    }
    
    func calculateDisplayedImageSize() -> CGSize {
        // Get the original image size
        if let uiImage = UIImage(named: imageName) {
            let originalSize = uiImage.size
            
            // Get the full screen size including areas outside safe area
            let fullScreenSize: CGSize
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                fullScreenSize = window.frame.size
            } else {
                fullScreenSize = containerSize
            }
            
            
            // Calculate the aspect ratios
            let imageRatio = originalSize.width / originalSize.height
            let containerRatio = fullScreenSize.width / fullScreenSize.height
            
            // For scaledToFill, the image fills the container
            if imageRatio > containerRatio {
                // Image is wider than container (relative to height)
                return CGSize(
                    width: fullScreenSize.height * imageRatio,
                    height: fullScreenSize.height
                )
            } else {
                // Image is taller than container (relative to width)
                return CGSize(
                    width: fullScreenSize.width,
                    height: fullScreenSize.width / imageRatio
                )
            }
        }
        return containerSize // Fallback to container size if image can't be loaded
    }
    
    private func calculateTapPoint() -> UnitPoint {
        .bottomTrailing
    }
}


@available(iOS 17.0, *)
#Preview {
    VerticalPanningView(imageName: "flowers")
}

@available(iOS 17.0, *)
#Preview {
    VerticalPanningView(imageName: "flowersLandscape")
}

@available(iOS 17.0, *)
#Preview {
    VerticalPanningView(imageName: "rocks")
}


