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
    let font = Font.custom("Avenir-Medium", size: 12)
    let fontBold = Font.custom("Avenir-Black", size: 12)
    
    var subtitleFormatted: String = ""
    
    var body: some View {
        Color.black
            .ignoresSafeArea() // Ignore just for the color
            .overlay(
                VStack(spacing: 0) {
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
                    
                    HStack(spacing: 0) {
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.white)
                                .opacity(0.05)
                            VStack(alignment: .center, spacing: 8) {
                                HStack {
                                    CustomText(content: content.incident3.boro, color: .red, font: font, scale: true, width: nil)
                                    CustomText(content: content.incident3.boxNumber, color: .red, font: font, scale: true, width: nil)
                                }
                                
                                VStack {
                                    CustomText(content: content.incident3.title, color: .white, font: font, scale: true, width: nil)
                                    if let subtitle = content.incident3.subtitle {
                                        CustomText(content: subtitle, color: .gray, font: font, scale: true, width: 50)
                                    }
                                    
                                }
                                CustomText(content: content.incident3.address, color: .red, font: font, scale: true, width: 120)
                            }
                        }
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

