//
//  FWWidgetLarge.swift
//  NYCFireWireWidgetExtension
//
//  Created by Alex Rhodes on 10/22/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import SwiftUI
import WidgetKit

struct FWWidgetLarge: View {
    let content: WidgetContent
    @State var incidents = [Incident]()
//    let font = Font.custom("Avenir-Book", size: 12)
    let font = Font.custom("Avenir-Black", size: 12)
    
    var subtitleFormatted: String = ""
    
    var body: some View {
        Color.black
            .ignoresSafeArea() // Ignore just for the color
            .overlay(
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        
                        IncidentView(incident: content.incident1, color: .black, opacity: 1)
                        IncidentView(incident: content.incident2, color: .white, opacity: 0.1)
                    }
                    
                    HStack(spacing: 0) {
                        
                        IncidentView(incident: content.incident3, color: .white, opacity: 0.1)

                        Image("logo")
                        
                    }
                }
            )
    }
}



struct FWWidgetLarge_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetLarge(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

