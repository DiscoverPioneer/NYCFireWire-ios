//
//  IncidentView.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import WidgetKit

struct IncidentView: View {
    let incident: Incident
    let color: Color
    let opacity: Double
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .opacity(opacity)
            VStack(spacing: 12) {
                HStack {
                        Text(incident.boro).modifier(TextModifier(content: "", color: .red, font: Font.bold, width: nil, lineLimit: 1))
                        Text(incident.boxNumber).modifier(TextModifier(content: "", color: .red, font: Font.book, width: nil, lineLimit: 1))
                }
                
                VStack(spacing: 2) {
                    Text(incident.title).modifier(TextModifier(content: "", color: .white, font: Font.bold, width: 100, lineLimit: 1))
                    if let subtitle = incident.subtitle {
                    Text(subtitle).modifier(TextModifier(content: "", color: .gray, font: Font.book, width: 100, lineLimit: 1))
                    }
                    Text(verbatim: incident.createdAt.smartStringFromDate()).modifier(TextModifier(content: incident.boro, color: .gray, font: Font.book, width: nil, lineLimit: 1))
                }
                Text(incident.address).modifier(TextModifier(content: incident.address, color: .red, font: Font.bold, width: 150, lineLimit: 1))
            }
        }
    }
}

struct IncidentView_Previews: PreviewProvider {
    static var previews: some View {
        IncidentView(incident: Incident.placeholder.incident3, color: .black, opacity: 1).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Font {
    static var bold: Font {
        return Font.custom("Avenir-Black", size: 14)
    }
    
    static var book: Font {
        return Font.custom("Ariel-Book", size: 14)
    }
}
