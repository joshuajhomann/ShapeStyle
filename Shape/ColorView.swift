//
//  ColorView.swift
//  Shape
//
//  Created by Joshua Homann on 9/9/23.
//

import SwiftUI

@Observable
final class ColorViewModel {
    var weight: Weight = .primary
    nonisolated init() { }
}

extension ColorViewModel {
    enum Item: String, CaseIterable, CustomStringConvertible, Hashable, Identifiable {
        static let sixColors = [#colorLiteral(red: 0.3824993372, green: 0.7338115573, blue: 0.2725535631, alpha: 1), #colorLiteral(red: 0.9938793778, green: 0.7221048474, blue: 0.1543448567, alpha: 1), #colorLiteral(red: 0.9527568221, green: 0.5061939955, blue: 0.1218801513, alpha: 1), #colorLiteral(red: 0.872074008, green: 0.2261180282, blue: 0.2434217036, alpha: 1), #colorLiteral(red: 0.5873757005, green: 0.2372255325, blue: 0.5935613513, alpha: 1), #colorLiteral(red: 0, green: 0.6172699332, blue: 0.8605360389, alpha: 1)].map(\.cgColor).map(Color.init(cgColor:))
        case red, linearGradient, radialGradient, angularGradient
        var id: String {
            rawValue
        }
        var description: String {
            rawValue.capitalized
        }
        var style: any ShapeStyle {
            switch self {
            case .red: .red
            case .linearGradient: LinearGradient(colors: Self.sixColors, startPoint: .leading, endPoint: .trailing)
            case .radialGradient: RadialGradient(colors: Self.sixColors, center: .center, startRadius: 0, endRadius: 150)
            case .angularGradient: AngularGradient(colors: Self.sixColors, center: .center)
            }
        }
    }
    enum Weight: String, CaseIterable, CustomStringConvertible, Hashable, Identifiable {
        case primary, secondary, tertiary, quaternary, quinary
        var id: String {
            rawValue
        }
        var description: String {
            rawValue.capitalized
        }
        func applied(to style: some ShapeStyle) -> any ShapeStyle {
            switch self {
            case .primary: style
            case .secondary: style.secondary
            case .tertiary: style.tertiary
            case .quaternary: style.quaternary
            case .quinary: style.quinary
            }
        }
    }
}

struct ColorView: View {
    @State private var viewModel = ColorViewModel()
    var body: some View {
        Picker("Weight", selection: $viewModel.weight) {
            ForEach(ColorViewModel.Weight.allCases, id: \.self) {
                Text($0.description)
            }
        }
        .pickerStyle(.segmented)
        ScrollView {
            LazyVGrid(columns: [.init(), .init(), .init()]) {
                ForEach(ColorViewModel.Item.allCases) { item in
                    Image(.waimea6).resizable().aspectRatio(contentMode: .fill)
                        .overlay(
                            VStack {
                                Circle().foregroundStyle(AnyShapeStyle(viewModel.weight.applied(to: item.style)))
                                Text(String(describing: item))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(.thinMaterial)
                                    )
                            },
                            alignment: .center
                        )
                }
            }
        }
    }
}
