//
//  BlendView.swift
//  Shape
//
//  Created by Joshua Homann on 9/9/23.
//

import SwiftUI

extension BlendMode: CaseIterable, CustomStringConvertible {
    public static var allCases: [BlendMode] = [
        normal, multiply, screen, overlay, darken, lighten, colorDodge, colorBurn, softLight, hardLight, difference, exclusion, hue, saturation, color, luminosity, sourceAtop, destinationOver, destinationOut, plusDarker, plusLighter]
    public var description: String {
        switch self {
        case .normal: "normal"
        case .multiply: "multiply"
        case .screen: "screen"
        case .overlay: "overlay"
        case .darken: "darken"
        case .lighten: "lighten"
        case .colorDodge: "colorDodge"
        case .colorBurn: "colorBurn"
        case .softLight: "softLight"
        case .hardLight: "hardLight"
        case .difference: "difference"
        case .exclusion: "exclusion"
        case .hue: "hue"
        case .saturation: "saturation"
        case .color: "color"
        case .luminosity: "luminosity"
        case .sourceAtop: "sourceAtop"
        case .destinationOver: "destinationOver"
        case .destinationOut: "destinationOut"
        case .plusDarker: "plusDarker"
        case .plusLighter: "plusLighter"
        @unknown default: ""
        }
    }
}

@Observable
final class BlendModeViewModel {
    var leftBlendMode: BlendMode = .normal
    var rightBlendMode: BlendMode = .normal
    var leftFill: Fill = .red
    var rightFill: Fill = .blue
    var leftStyle: any ShapeStyle {
        shapeStyle(for: leftFill, blendMode: leftBlendMode)
    }
    var rightStyle: any ShapeStyle {
        shapeStyle(for: rightFill, blendMode: rightBlendMode)
    }
    private let paint = ImagePaint(image: Image(.waimea6), scale: 0.5e-4)
    var separation = 100.0
    nonisolated init() { }
    private func shapeStyle(for fill: Fill, blendMode: BlendMode) -> any ShapeStyle {
        switch fill {
        case .blue: .blue.blendMode(blendMode)
        case .red: .red.blendMode(blendMode)
        case .image: paint.blendMode(blendMode)
        }
    }
}

extension BlendModeViewModel {
    enum Fill: String, CaseIterable, CustomStringConvertible, Hashable, Identifiable {
        case red, blue, image
        var id: String {
            rawValue
        }
        var description: String {
            rawValue.capitalized
        }
    }
}

struct BlendView: View {
    @State private var viewModel = BlendModeViewModel()
    var body: some View {
        Circle()
            .offset(x: -viewModel.separation)
            .foregroundStyle(AnyShapeStyle(viewModel.leftStyle))
            .overlay(
                Circle()
                    .foregroundStyle(AnyShapeStyle(viewModel.rightStyle))
                    .offset(x: viewModel.separation)
            )
            .padding()
            .background(Image(.waimea6).resizable().aspectRatio(contentMode: .fill))
            .inspector(isPresented: .constant(true)) {
                Form {
                    VStack {
                        fillPicker("Left Fill", selection: $viewModel.leftFill)
                        blendPicker("Left Blend", selection: $viewModel.leftBlendMode)
                        fillPicker("Right Fill", selection: $viewModel.rightFill)
                        blendPicker("Right Blend", selection: $viewModel.rightBlendMode)
                        Slider(value: $viewModel.separation, in: 0...250.0) { Text("Separation") }
                    }
                }.padding()
            }
    }
    private func fillPicker(_ title: String, selection: Binding<BlendModeViewModel.Fill>) -> some View {
        Picker(title, selection: selection) {
            ForEach(BlendModeViewModel.Fill.allCases, id: \.self) {
                Text($0.description)
            }
        }
        .pickerStyle(.segmented)
    }
    private func blendPicker(_ title: String, selection: Binding<BlendMode>) -> some View {
        Picker(title, selection: selection) {
            ForEach(BlendMode.allCases, id: \.self) {
                Text($0.description)
            }
        }
        .pickerStyle(.menu)
    }
}
