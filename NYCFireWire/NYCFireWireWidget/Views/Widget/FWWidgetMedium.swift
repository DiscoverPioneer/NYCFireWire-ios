//
//  FWWidgetMedium.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import WidgetKit

struct FWWidgetMedium: View {
    let content: WidgetContent
    let fontBold = Font.custom("Ariel-Black", size: 12)
    let font = Font.custom("Ariel-Medium", size: 12)
    @State var incidents = [Incident]()
    
    
    
    var body: some View {
        Color.black
            .ignoresSafeArea() // Ignore just for the color
            .overlay(
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white)
                    .opacity(0.15)
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
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white)
                    .opacity(0.1)
                
                
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        CustomText(content: content.incident2.boro, color: .red, font: font, scale: true, width: nil)
                        CustomText(content: content.incident2.boxNumber, color: .red, font: font, scale: true, width: nil)
                    }
                    
                    VStack {
                        CustomText(content: content.incident2.title, color: .white, font: font, scale: true, width: nil)
                        if let subtitle = content.incident2.subtitle {
                            CustomText(content: subtitle, color: .gray, font: font, scale: true, width: 100)
                        }
                    }
                    CustomText(content: content.incident2.address, color: .red, font: font, scale: true, width: 120)
                }
                .padding(10)
            }
        }
       )
    }
    
}



struct FWWidgetMedium_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetMedium(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

