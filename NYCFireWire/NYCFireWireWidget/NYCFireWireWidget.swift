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
        let feedType = UserDefaults.standard.string(forKey: "selectedFeedType") ?? "NYC"
        if let email = UserDefaults.standard.string(forKey: UserDefaultKeys.userEmailKey.rawValue),
           let token =  UserDefaults.standard.string(forKey: UserDefaultKeys.userTokenKey.rawValue) {
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
        }
    }
    
    func placeholder(in context: Context) -> WidgetContent {
        Incident.placeholder
    }
}

struct NYCFireWireWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("\(entry.date)")
    }
}

@main
struct NYCFireWireWidget: Widget {
    let kind: String = "NYCFireWireWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NYCFireWireWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(kind)
        .description("This is an example widget.")
    }
}

struct NYCFireWireWidget_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetMedium(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemMedium))
//        NYCFireWireWidgetEntryView(entry: Incident.placeholder)
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
