//
//  EventView.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EventView: View {
    let incident: Incident
    let color: Color
    let fontBold = Font.custom("Ariel-Black", size: 12)
    let font = Font.custom("Ariel-Medium", size: 12)
    
    var body: some View {
        Text("hello")
//        Color.black
//            .ignoresSafeArea() // Ignore just for the color
//            .overlay(
////                VStack(spacing: 0) {
////                    HStack(spacing: 0) {
//
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(Color.white)
//                                .opacity(0.15)
//                            VStack(alignment: .center, spacing: 8) {
//                                HStack {
//                                    CustomText(content: incident.boro, color: .red, font: font, scale: true, width: nil)
//                                    CustomText(content: incident.boxNumber, color: .red, font: font, scale: true, width: nil)
//                                }
//
//                                VStack {
//                                    CustomText(content: incident.title, color: .white, font: font, scale: true, width: nil)
//                                    if let subtitle = incident.subtitle {
//                                        CustomText(content: subtitle, color: .gray, font: font, scale: true, width: 100)
//                                    }
//
//                                }
//                                CustomText(content: incident.address, color: .red, font: font, scale: true, width: 120)
//
//
//                            }
////                        }
////                    }
//                }
//            )
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(incident: Incident.placeholder.incident1, color: .black).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
