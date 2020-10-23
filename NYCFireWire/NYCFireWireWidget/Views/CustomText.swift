//
//  CustomText.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI

struct TextModifier: ViewModifier {
    let content: String
    let color: Color
    let font: Font
    let width: CGFloat?
    let lineLimit: Int?
    
    func body(content: Content) -> some View {
            content
                .font(font)
                .foregroundColor(color)
                .frame(width: width ?? .none)
                .lineLimit(lineLimit ?? .none)
        }
}

