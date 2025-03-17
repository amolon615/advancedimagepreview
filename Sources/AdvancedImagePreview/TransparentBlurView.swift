//
//  TransparentBlurView.swift
//  AdvancedImagePreview
//
//  Created by amolonus on 26/03/2025.
//
import SwiftUI
import UIKit

@available(iOS 17.0, *)
struct TransparentBlurView: UIViewRepresentable {
    var removeAllFilters: Bool = false
    func makeUIView(context: Context) -> CustomBlurView {
        let view = CustomBlurView(effect: .init(style: .systemUltraThinMaterial))
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: CustomBlurView, context: Context) {  }
}

@available(iOS 17.0, *)
class CustomBlurView: UIVisualEffectView {
    init(effect: UIBlurEffect) {
        super.init(effect: effect)
        setup()
    }
    
    func setup() {
        removeFilters()
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            DispatchQueue.main.async {
                self.removeFilters()
            }
        }
    }
    
    func hideView(_ status: Bool) {
        alpha = status ? 0 : 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func removeFilters() {
        if let filterLayer = layer.sublayers?.first {
            filterLayer.filters = []
        }
    }
}
