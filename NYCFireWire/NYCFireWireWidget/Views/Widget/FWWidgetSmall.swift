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
        IncidentView(incident: content.incident1, color: .black, opacity: 1)
    }
}

struct FWWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetSmall(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
