//
//  FWWidgetSmall.swift
//  NYCFireWire - Prod
//
//  Created by Alex Rhodes on 10/12/20.
//  Copyright © 2020 Pioneer Mobile Applications, LLC. All rights reserved.
//

import SwiftUI
import WidgetKit

enum IncidentProperties: String {
    case title = "title"
    case subtitle = "subtitle"
    case boxNumber = "box_number"
    case boro = "boro"
}

struct FWWidgetMedium: View {
    let content: WidgetContent
    @State var isOpen1: Bool = true
    @State var isOpen2: Bool = false
    @State var isOpen3: Bool = false
    @State var incidents = [Incident]()
    
    func createIncidents() {
        incidents.append(content.incident1)
        incidents.append(content.incident2)
        incidents.append(content.incident3)

    }
    
    func changeState(state: Bool) {
        if state == isOpen1 {
            isOpen1 = true
            isOpen2 = false
            isOpen3 = false
        } else if state == isOpen2 {
            isOpen1 = false
            isOpen2 = true
            isOpen3 = false
        } else if state == isOpen3 {
            isOpen1 = false
            isOpen2 = false
            isOpen3 = true
        }
    }
    
    func createCustomText(content: IncidentProperties) -> CustomText {
        createIncidents()
        var values = [String]()
        
        switch content {
        case .boro:
           values = incidents.map({"\($0.boro)"})
        case .title:
            values = incidents.map({"\($0.title)"})

        case .subtitle:
            values = incidents.map({
                var value = ""
                if let sub = $0.subtitle {
                    value = sub
                }
                return "\(value)"
            })
        case .boxNumber:
            values = incidents.map({"\($0.title)"})

        }
        
        if isOpen1 {
           return CustomText(content: values[0], color: .red, font: .headline, scale: nil)
        }
        
        if isOpen2 {
            return CustomText(content: values[1], color: .red, font: .headline, scale: nil)
        }
        
        if isOpen3 {
            return CustomText(content: values[2], color: .red, font: .headline, scale: nil)
        }
        
        return CustomText(content: "", color: .red, font: .body, scale: false)
    }

    var body: some View {
        Color.black
            .ignoresSafeArea() // Ignore just for the color
            .overlay(
                HStack{
                    VStack(alignment: .leading, spacing: 30) {
                        WidgetButton(isOpen: true, incident: content.incident1, image: "fire", action: {
                            print("tapped")
                            self.changeState(state: isOpen1)
                        })
                        WidgetButton(isOpen: false, incident:
                                        content.incident2, image: "fire", action: {
                                            print("tapped")
                            self.changeState(state: isOpen2)
                        })
                        WidgetButton(isOpen: false, incident: content.incident3, image: "fire", action: {
                            print("tapped")
                            self.changeState(state: isOpen3)

                        })
                    }
                    .padding()
                    
                    ZStack {
                    Rectangle()
                        .foregroundColor(Color.white)
                        .opacity(0.1)
                        
                        
                    VStack(alignment: .center, spacing: 30) {
                        HStack(spacing: 80) {
//                            createCustomText(content: .boro)
                            CustomText(content: content.incident1.boxNumber, color: .red, font: .headline, scale: nil)
                        }

                        VStack {
                            CustomText(content: content.incident1.title, color: .white, font: .headline, scale: nil)
                            if let subtitle = content.incident1.subtitle {
                                CustomText(content: subtitle, color: .gray, font: .body, scale: nil)
                            }
                        }
                        HStack {
                            CustomText(content: content.incident1.address, color: .red, font: .subheadline, scale: true)
                        }
                    }
                    .padding(10)
                }
                }
            )
    }
}

struct ButtonControl: View  {
    let isOpen: Bool
    
    var body: some View {
        Text("")
    }
    
}

struct CustomText: View {
    let content: String
    let color: Color
    let font: Font
    let scale: Bool?
    
    var body: some View {
        if scale == true {
            Text(content)
                .font(font)
                .foregroundColor(color)
                .scaledToFill()
        } else {
            Text(content)
                .font(font)
                .foregroundColor(color)
        }
            
    }
}

struct WidgetButton: View {
    @State var isOpen: Bool
    let incident: Incident
    let image: String
    let action: () -> ()
    
    var body: some View {
        HStack {
            Button(action: {
                self.isOpen.toggle()
                print("button tapped")
                action()
            }, label: {
                HStack {
                    CustomText(content: incident.title, color: isOpen ? .gray : .white, font: .headline, scale: nil)
                }
            })
            
            if let image = image {
                Image(image)
            }
        }
        .shadow(color: isOpen ? .gray : .clear, radius: 0, x: 0.5, y: 0.5)
    }
}

struct FWWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        FWWidgetMedium(content: Incident.placeholder).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
