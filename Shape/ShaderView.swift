//
//  ShaderView.swift
//  Shape
//
//  Created by Joshua Homann on 9/9/23.
//

import SwiftUI


enum ShaderStyle: String, CaseIterable, CustomStringConvertible, Hashable, Identifiable {
    case mix, bilinear, colorize, ripple, channelOffset, vornoi, vornoiManhattan, vornoiText, truchetQuadCircleText, truchetQuadLine, truchetQuadCircle
    var id: String {
        rawValue
    }
    var description: String {
        rawValue.capitalized
    }
}


struct ShaderView: View {
    let startDate = Date()
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(), .init()]) {
                ForEach(ShaderStyle.allCases) { style in
                    switch style {
                    case .mix:
                        TimelineView(.animation) { context in
                            Text(
                            """
                            Lorem ipsum dolor sit amet
                            \(Text("INTERPOLATE").font(.system(size: 100, weight: .black, design: .monospaced))
                                .foregroundStyle(
                                    ShaderLibrary.mix(
                                        .color(.yellow),
                                        .color(.purple),
                                        .float(startDate.timeIntervalSinceNow),
                                        .float(0.1)
                                    )
                                )
                            )
                            consectetur adipiscing elit
                            """)
                        }
                    case .bilinear:
                        Circle()
                            .visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.bilinear(.float2(proxy.size.width, proxy.size.height)))
                            }
                    case .colorize:
                        Image(.puyo).resizable().visualEffect { content, proxy in
                            content.colorEffect(ShaderLibrary.colorize(.color(Color.yellow)))
                        }
                    case .channelOffset:
                        TimelineView(.animation) { context in
                            let θ = startDate.timeIntervalSinceNow
                            let r = 5.0
                            Rectangle().fill(.clear).aspectRatio(1, contentMode: .fill).overlay(
                                Image(.nasa).visualEffect { content, proxy in
                                    content.layerEffect(
                                        ShaderLibrary.channelOffset(
                                            .float2(r * sin(θ), r * cos(θ)),
                                            .float2(r * sin(θ + .pi), r * cos(θ + .pi)),
                                            .float2(r * sin(θ + .pi), r * cos(θ + .pi))
                                        ),
                                        maxSampleOffset: .zero
                                    )
                                }
                            )
                        }
                    case .vornoi:
                        TimelineView(.animation) { context in
                            Rectangle().aspectRatio(1, contentMode: .fill).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.vornoi(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    case .vornoiManhattan:
                        TimelineView(.animation) { context in
                            Rectangle().aspectRatio(1, contentMode: .fill).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.vornoiManhattan(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    case .vornoiText:
                        TimelineView(.animation) { context in
                            Text("VORNOI").font(.system(size: 130)).fontWeight(.black).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.vornoi(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    case .truchetQuadLine:
                        TimelineView(.animation) { context in
                            Rectangle().aspectRatio(1, contentMode: .fill).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.truchetQuadLine(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    case .ripple:
                        TimelineView(.animation) { context in
                            Image(.puyo).resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .visualEffect { content, proxy in
                                    content
                                        .distortionEffect(
                                            ShaderLibrary
                                                .ripple(
                                                    .float2(proxy.size.width, proxy.size.height),
                                                    .float2(0.15, 0.15),
                                                    .float(20),
                                                    .float(startDate.timeIntervalSinceNow)
                                                ),
                                            maxSampleOffset: .zero
                                        )
                                }
                        }
                    case .truchetQuadCircle:
                        TimelineView(.animation) { context in
                            Rectangle().aspectRatio(1, contentMode: .fill).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.truchetQuadCircle(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    case .truchetQuadCircleText:
                        TimelineView(.animation) { context in
                            Text("TRUCHET").font(.system(size: 110)).fontWeight(.black).visualEffect { content, proxy in
                                content.colorEffect(ShaderLibrary.truchetQuadCircle(.float2(proxy.size.width, proxy.size.height), .float(startDate.timeIntervalSinceNow)))
                            }
                        }
                    }
                }
            }
        }
    }
}
