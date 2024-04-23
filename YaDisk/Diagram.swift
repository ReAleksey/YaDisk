//
//  Diagram.swift
//  YaDisk
//
//  Created by Алексей Решетников on 19.03.2024.
//

import Foundation
import SwiftUI

struct CirclePart: Identifiable {
    let id = UUID()
    let color: Color
    var storage: CGFloat
    var percent: CGFloat
}

class DiagramContainer: ObservableObject {
    @Published var chartData =  [
        CirclePart(color: Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), storage: 0.0, percent: 0.0),
        CirclePart(color: Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)), storage: 0.0, percent: 0.0),
    ]
    
    func updateChartData(totalSpace: Double, usedSpace: Double) {
        
        chartData[0].storage = CGFloat(usedSpace)
        chartData[1].storage = CGFloat(totalSpace)
        
        chartData[0].percent = CGFloat((usedSpace/(usedSpace+totalSpace))*100)
        chartData[1].percent = CGFloat((totalSpace/(usedSpace+totalSpace))*100)
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
            ForEach(chartDataObj.chartData) { part in
                Circle()
                    .trim(from: calculateStartPercent(part: part),
                          to: calculateEndPercent(part: part))
                    .stroke(part.color, lineWidth: 40)
                    .scaleEffect(isTapped(part: part) ? 1.05 : 1.0)
                    .animation(.spring(), value: indexOfTappedSlice)
            }
            Text(totalMemoryText)
                .font(.largeTitle)
                .foregroundColor(.black)
        }
        .frame(width: 230, height: 230)
    }
    
    
    private func calculateStartPercent(part: CirclePart) -> CGFloat {
        guard let index = chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) else { return 0 }
        return index == 0 ? 0.0 : chartDataObj.chartData[index - 1].percent / 100
    }
    
    private func calculateEndPercent(part: CirclePart) -> CGFloat {
        guard let index = chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) else { return 0 }
        return index == 0 ? part.percent / 100 : (part.percent + chartDataObj.chartData[index - 1].percent) / 100
    }

    private var totalMemoryText: String {
        let totalMemory = (diskInfo.total_space + diskInfo.used_space) / 8 / 1024 / 1024 / 1024
        return String(format: "%.2f ГБ", totalMemory)
    }
    
    private var listView: some View {
        VStack {
            ForEach(chartDataObj.chartData) { part in
                chartRowView(part: part)
            }
        }
    }

    private func chartRowView(part: CirclePart) -> some View {
        HStack {
            let storageText = String(format: "%.2f", Double(part.storage)) + " ГБ"
            let statusText = partStatusText(part: part)
            let completeText = storageText + statusText
            
            Text(completeText)
                .onTapGesture {
                    indexOfTappedSlice = (indexOfTappedSlice == chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) ? -1 : chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) ?? -1)
                }
                .font(isTapped(part: part) ? .headline : .subheadline)
                .fixedSize(horizontal: true, vertical: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
            RoundedRectangle(cornerRadius: 3)
                .fill(part.color)
                .frame(width: 20, height: 20)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    private func partStatusText(part: CirclePart) -> String {
        if let index = chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) {
            return index == 0 ? " - занято" : " - свободно"
        }
        return ""
    }
    
    private func isTapped(part: CirclePart) -> Bool {
        guard let index = chartDataObj.chartData.firstIndex(where: {$0.id == part.id}) else { return false }
        return index == indexOfTappedSlice
    }
}
