//
//  CustomText.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI

struct CustomText: View {
    let content: String
    let color: Color
    let font: Font
    let scale: Bool?
    let width: CGFloat?
    
    var body: some View {
        if scale == true {
            Text(content)
                .font(font)
                .foregroundColor(color)
                .scaledToFill()
                .frame(width: width ?? .none)
                
        } else {
            Text(content)
                .font(font)
                .foregroundColor(color)
                .frame(width: width ?? .none)
        }
        
    }
}

struct CustomText_Previews: PreviewProvider {
    static var previews: some View {
        CustomText(content: "HELLOO", color: .black, font: Font.custom("Ariel-Book", size: 12), scale: true, width: nil)
    }
}
