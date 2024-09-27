//
// TransitionShader.swift
// Inferno
// https://www.github.com/twostraws/Inferno
// See LICENSE for license information.
//

import SwiftUI

/// A shader able to act as a SwiftUI transition.
struct TransitionShader: Hashable, Identifiable {
    /// The unique, random identifier for this shader, so we can show these
    /// things in a loop.
    var id = UUID()
    
    /// The human-readable name for this shader. This must work with the
    /// String-ShaderName extension so the name matches the underlying
    /// Metal shader function name.
    var name: String
    
    /// the SwiftUI transition to use for this shader.
    var transition: AnyTransition

    /// We need a custom equatable conformance to compare only the IDs, because
    /// the `transition` property blocks the synthesized conformance.
    static func ==(lhs: TransitionShader, rhs: TransitionShader) -> Bool {
        lhs.id == rhs.id
    }

    /// We need a custom hashable conformance to compare only the IDs, because
    /// the `transition` property blocks the synthesized conformance.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// An example shader used for Xcode previews.
    static let example = shaders[0]

    /// All the transition shaders we want to show.
    static let shaders = [
       
        TransitionShader(name: "Crosswarp (→)", transition: .crosswarpLTR)
    ]
}
