//
//  ChartView.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/29/26.
//

import SwiftUI
import Charts

struct ChartView: View {
    let historical: [ValueInfo]
    var body: some View {
        Chart(historical) { value in
            AreaMark(
                x: .value("Day", value.date),
                y: .value("Value", value.value)
            )
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    let mockData = [
        ValueInfo(date: "2025-01-11", value: 1),
        ValueInfo(date: "2025-02-09", value: 21),
        ValueInfo(date: "2025-02-10", value: 304),
        ValueInfo(date: "2025-02-13", value: 20),
    ]

    ChartView(historical: mockData)
}

