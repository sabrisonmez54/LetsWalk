//
//  File.swift
//  
//
//  Created by Samu András on 2020. 02. 19..
//

import SwiftUI

public struct MultiLineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var data:[MultiLineChartData]
    public var title: String
    public var legend: String?
    public var labels: [Date]
    public var names: [String]
    public var multiLegend: [(color: Color, location: String)]
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize: CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    @State private var currentLabelIndex: Int = 0
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: [Bool] = [false,false]
    @State private var currentValue: Double = 2 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot.contains(true)) {
                HapticFeedback.playSelection()
            }
            
        }
    }
    
    var globalMin:Double {
        if let min = data.flatMap({$0.onlyPoints()}).min() {
            return min
        }
        return 0
    }
    
    var globalMax:Double {
        if let max = data.flatMap({$0.onlyPoints()}).max() {
            return max
        }
        return 0
    }
    
    var frame = CGSize(width: 180, height: 120)
    private var rateValue: Int?
    
    public init(labels: [Date],
                data: [([Double], GradientColor)],
                title: String,
                legend: String? = nil,
                multiLegend: [(Color,String)],
                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize = ChartForm.medium,
                rateValue: Int? = nil,
                dropShadow: Bool = true,
                valueSpecifier: String = "%.1f",
                names:[String]) {
        self.labels = labels
        self.names = names
        self.data = data.map({ MultiLineChartData(points: $0.0, gradient: $0.1)})
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form
        frame = CGSize(width: self.formSize.width, height: self.formSize.height/2)
        self.rateValue = rateValue
        self.dropShadow = dropShadow
        self.valueSpecifier = valueSpecifier
        self.multiLegend = multiLegend
        
    }
    
    public var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 0)
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .frame(width: frame.width, height: 240, alignment: .center)
                .shadow(radius: self.dropShadow ? 8 : 0)
                
            VStack(alignment: .leading){
                if(!self.showIndicatorDot.contains(true)){
                    VStack(alignment: .leading, spacing: 8){
                        Text(self.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        if (self.legend != nil) {
                            HStack {
                                if (rateValue ?? 0 >= 0){
                                    Image(systemName: "arrow.up")
                                }else{
                                    Image(systemName: "arrow.down")
                                }
                                Text("\(rateValue ?? 0)%")
                            }
                            Text(self.legend!)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        
                            HStack {
                                    ForEach(0..<self.multiLegend.count) { i in
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(multiLegend[i].color)
                                            .frame(width: 15, height: 10)
                                        Text(multiLegend[i].location)
                                            .font(.callout)
                                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                            }
                        
                       

                      
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.1))
                    .padding([.leading, .top])
                }else{
                    HStack{
                        Spacer()
                        VStack{
                            Text("\(labels[self.currentLabelIndex], style: .date)")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .offset(x: 0, y: 30)
                            Text("\(self.currentValue, specifier: self.valueSpecifier) pcm")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .offset(x: 0, y: 30)
                            Text("\(names[self.currentLabelIndex])")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .offset(x: 0, y: 30)
                        }
                        Spacer()
                    }
                    .transition(.scale)
                }
                Spacer()
                GeometryReader{ geometry in
                    ZStack{
                        ForEach(0..<self.data.count) { i in
                            MultiLine(data: self.data[i],
                                      frame: .constant(geometry.frame(in: .local)),
                                      touchLocation: self.$touchLocation,
                                      showIndicator: self.$showIndicatorDot[i],
                                      minDataValue: .constant(self.globalMin),
                                      maxDataValue: .constant(self.globalMax),
                                      showBackground: false,
                                      gradient: self.data[i].getGradient(),
                                      index: i) .gesture(DragGesture()
                                                            .onChanged({ value in
                                                                self.touchLocation = value.location
                                                                self.showIndicatorDot[i] = true
                                                                self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height, index: i)
                                                            })
                                                            .onEnded({ value in
                                                                self.showIndicatorDot[i] = false
                                                            })
                                      )
                        }
                    }
                }
                .frame(width: frame.width, height: frame.height + 20 )
                
                .offset(x: 0, y: 20)
                
            }.frame(width: self.formSize.width, height: self.formSize.height)
        }
        
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat, index: Int) -> CGPoint {
        
        let points = self.data[index].onlyPoints()
        
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            self.currentLabelIndex = index
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct MultiWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            MultiLineChartView(data: [([8,23,54,32,12,37,7,23,43], GradientColors.orange)], title: "Line chart", legend: "Basic", multiLegend: [(color: Colors.GradientNeonBlue,location: "Calder"),(color:Colors.GradientPurple,location: "lincoln")])
//                .environment(\.colorScheme, .light)
        }
    }
}
