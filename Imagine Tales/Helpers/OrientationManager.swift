//
//  OrientationManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/4/24.
//


import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func orientationChanged() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}