//
//  Diagram.swift
//  YaDisk
//
//  Created by Алексей Решетников on 19.03.2024.
//

import Foundation
import SwiftUI

struct CirclePart {
    let color: Color
    var storage: CGFloat
    var percent: CGFloat
}

class DiagramContainer: ObservableObject {
    @Published var chartData =  [
        CirclePart(color: Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), storage: 0.0, percent: 0.0),
        CirclePart(color: Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)), storage: 0.0, percent: 0.0),
    ]
    
    func updateChartData(totalSpace: Float, usedSpace: Float) {
        
        chartData[0].storage = CGFloat(usedSpace)
        chartData[1].storage = CGFloat(totalSpace)
        
        chartData[0].percent = CGFloat((usedSpace/(usedSpace+totalSpace))*100)
        chartData[1].percent = CGFloat((totalSpace/(usedSpace+totalSpace))*100)
        
        for index in 0..<chartData.count {
            print ("index", index)
            print ("from", index == 0 ? 0.0 : chartData[index - 1].percent / 100)
            print ("to", chartData[index].percent / 100)
        }
    }
}

struct DiagramView: View {
    
    @ObservedObject var chartDataObj: DiagramContainer
    @State private var indexOfTappedSlice = -1
    var diskInfo: DiskInfo
    
    var body: some View {
        VStack {
            circleView
                .frame(width: 150, height: 300)
                .onAppear() {
                    chartDataObj.updateChartData(totalSpace: diskInfo.total_space/8/1024/1024/1024, usedSpace: diskInfo.used_space/8/1024/1024/1024)
                }
            listView
                .padding(8)
                .frame(width: 300, alignment: .trailing)
        }
    }
    
    private var circleView: some View {
        ZStack {
            ForEach(0..<chartDataObj.chartData.count) { index in
              
                Circle()
                    .trim(from: index == 0 ? 0.0 : chartDataObj.chartData[index - 1].percent / 100,
                          to: index == 0 ? chartDataObj.chartData[index].percent / 100 : (chartDataObj.chartData[index].percent+chartDataObj.chartData[index - 1].percent)/100)
                    .stroke(chartDataObj.chartData[index].color, lineWidth: 100)
                    .scaleEffect(index == indexOfTappedSlice ? 1.1 : 1.0)
                    .animation(.spring, value: 1)
            }
        }
    }

    private var listView: some View {
        return VStack {
            ForEach(0..<chartDataObj.chartData.count) { index in
                chartRowView(index: index)
            }
        }
    }
    
    private func chartRowView(index: Int) -> some View {
        HStack {
            Text(String(format: "%.2f", Double(chartDataObj.chartData[index].storage)) + " ГБ")
                .onTapGesture {
                    indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                }
                .font(indexOfTappedSlice == index ? .headline : .subheadline)
            RoundedRectangle(cornerRadius: 3)
                .fill(chartDataObj.chartData[index].color)
                .frame(width: 20, height: 20)
        }
    }
}
