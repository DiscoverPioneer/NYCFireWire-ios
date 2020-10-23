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
                    IncidentView(incident: content.incident1, color: .black, opacity: 1)
                    IncidentView(incident: content.incident2, color: .white, opacity: 0.1)
                }
            )
    }
}



struct FWWidgetMedium_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetMedium(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

