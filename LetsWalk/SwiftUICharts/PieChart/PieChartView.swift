//
//  PieChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartView : View {
    public var data: [Double]
    public var labels: [String]
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var formSize:CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    
    @State private var showValue = false
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
              
            }
        }
    }
    @State private var currentIndex: Int = 0 {
        didSet{
            if(oldValue != currentIndex && self.showValue) {
                HapticFeedback.playSelection()
                
            }
        }
    }
    
    public init(labels: [String], data: [Double], title: String, legend: String? = nil, style: ChartStyle = Styles.pieChartStyleOne, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, valueSpecifier: String? = "%.0f"){
        self.labels = labels
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.formSize = form!
        if self.formSize == ChartForm.large {
            self.formSize = ChartForm.extraLarge
        }
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
    }
    
    public var body: some View {
        ZStack{
            Rectangle()
                .fill(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            if data.allSatisfy { $0 == 0.0} {
                Text("There is no percentage of pollen in the air today.").font(.subheadline)
            } else {
                VStack(alignment: .leading){
                    HStack{
                        if(!showValue){
                            Text(self.title)
                                .font(.headline)
                                .foregroundColor(Color(.label))
                        }else{
                            Text("\(self.currentValue, specifier: self.valueSpecifier) % \(labels[currentIndex])")
                                .font(.headline)
                                .foregroundColor(Color(.label))
                            
                        }
                        Spacer()
                        Image(systemName: "chart.pie.fill")
                            .imageScale(.large)
                            .foregroundColor(self.style.legendTextColor)
                    }.padding()
                   
                        PieChartRow(data: data, backgroundColor: self.style.backgroundColor, accentColor: self.style.accentColor, gradient:self.style.gradientColor, showValue: $showValue, currentValue: $currentValue, currentIndex: $currentIndex)
                            .foregroundColor(self.style.accentColor).padding(self.legend != nil ? 0 : 12).offset(y:self.legend != nil ? 0 : -10)
                        if(self.legend != nil) {
                            Text(self.legend!)
                                .font(.headline)
                                .foregroundColor(Color(.secondaryLabel))
                                .padding()
                        }
                    
                }
            
            }
        }.frame(width: self.formSize.width, height: self.formSize.height)
        .onDisappear {
            showValue = false
        }
    }
}

#if DEBUG
struct PieChartView_Previews : PreviewProvider {
    static var previews: some View {
        PieChartView(labels: ["oak","honey","ragweed","hickory","mugwort","no pollen"],data:[56,78,53,65,54, 55], title: "Title", legend: "Legend")
    }
}
#endif
