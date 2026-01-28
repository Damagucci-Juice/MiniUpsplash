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
        }
    }
}

#Preview {
    let mockData = [
        ValueInfo(date: "2025-01-11", value: 30),
        ValueInfo(date: "2025-02-09", value: 30),
        ValueInfo(date: "2025-02-10", value: 30),
        ValueInfo(date: "2025-02-13", value: 30),
    ]

    ChartView(historical: mockData)
}

