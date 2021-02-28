//
//  NYCFireWireWidget.swift
//  NYCFireWireWidget
//
//  Created by Alex Rhodes on 10/21/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

var widgetContent: WidgetContent?

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        if let entry = widgetContent {
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetContent>) -> Void) {
        var entries: [WidgetContent] = []
        let feedType = UserDefaultsSuite().stringFor(key: .selectedFeedType) ?? "NYC"
        if let email = UserDefaultsSuite().userEmail,
           let token = UserDefaultsSuite().token {
            let controller = APIController(email: email, token: token)
            controller.getAllIncidents(feedType: feedType) { (incidents) in
                widgetContent = WidgetContent(date: Date(), incident1: incidents[0], incident2: incidents[1], incident3: incidents[2])
                
                let currentDate = Date()
                let entryDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                if let entry = widgetContent {
                    let widget = WidgetContent(date: entryDate, incident1: entry.incident1, incident2: entry.incident2, incident3: entry.incident3)
                    entries.append(widget)
                }
                
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        } else {
            let currentDate = Date()
            let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
            
            let entry = WidgetContent(date: Date(), incident1: Incident.placeholder.incident1, incident2: Incident.placeholder.incident2, incident3: Incident.placeholder.incident3)
            
            for _ in 0...100 {
                let widget = WidgetContent(date: entryDate, incident1: entry.incident1, incident2: entry.incident2, incident3: entry.incident3)
                entries.append(widget)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> WidgetContent {
        Incident.placeholder
    }
}

struct NYCFireWireWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            FWWidgetSmall(content: entry).previewContext(WidgetPreviewContext(family: .systemSmall))
        case .systemMedium:
            FWWidgetMedium(content: entry).previewContext(WidgetPreviewContext(family: .systemMedium))
        case .systemLarge:
            FWWidgetLarge(content: entry).previewContext(WidgetPreviewContext(family: .systemLarge))
        @unknown default:
            EmptyView()
        }
    }
}

@main
struct NYCFireWireWidget: Widget {
    let kind: String = "NYCFireWireWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NYCFireWireWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fire Wire")
        .description("This is a display of the most recent incidents.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NYCFireWireWidget_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetSmall(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemSmall))
        FWWidgetMedium(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemMedium))
        FWWidgetLarge(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
