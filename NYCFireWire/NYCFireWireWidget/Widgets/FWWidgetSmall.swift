//
//  FWWidgetSmall.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import WidgetKit

struct FWWidgetSmall: View {
    let content: WidgetContent
    let fontBold = Font.custom("Ariel-Black", size: 12)
    let font = Font.custom("Ariel-Medium", size: 12)
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.black)
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    CustomText(content: content.incident1.boro, color: .red, font: font, scale: true, width: nil)
                    CustomText(content: content.incident1.boxNumber, color: .red, font: font, scale: true, width: nil)
                }
                
                VStack {
                    CustomText(content: content.incident1.title, color: .white, font: font, scale: true, width: nil)
                    if let subtitle = content.incident1.subtitle {
                        CustomText(content: subtitle, color: .gray, font: font, scale: true, width: 100)
                    }
                    
                }
                CustomText(content: content.incident1.address, color: .red, font: font, scale: true, width: 120)
                
                
            }
        }
    }
}

struct FWWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetSmall(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
