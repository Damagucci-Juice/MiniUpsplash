//
//  ChartView.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/29/26.
//

import SwiftUI
import Charts

struct ChartView: View {
    @State private var selectedDate: String?
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

            if let selectedDate,
               let value = historical.first(where: { value in
                    value.date == selectedDate
                })
            {
                RectangleMark(x: .value("Day", selectedDate))
                    .foregroundStyle(.primary.opacity(0.2))
                    .annotation(
                        position: .leading,
                        alignment: .center, spacing: 0
                    ) {
                        TrendAnnotationView(values: historical, date: selectedDate, valueData: value.value)
                    }
                    .accessibilityHidden(true)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartOverlay { (chartProxy: ChartProxy) in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle()) // 터치 영역 확보
                    .gesture(
                        DragGesture(minimumDistance: 0) // 터치 시작부터 감지
                            .onChanged { value in
                                let origin = geometry[chartProxy.plotAreaFrame].origin
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )
                                // x축 위치에 해당하는 날짜 값 추출
                                if let date: String = chartProxy.value(atX: location.x) {
                                    selectedDate = date
                                }
                            }
                            .onEnded { _ in
                                selectedDate = nil // 손을 떼면 어노테이션 제거
                            }
                    )
            }
        }
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


struct TrendAnnotationView: View {
    let values: [ValueInfo]
    let date: String
    let valueData: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(date)
                .font(.headline)
            Divider()
            ForEach(values, id: \.self.id) { origin in
                Text("\(origin.date): \(NumberManager.shared.convert(origin.value))")
            }
        }
        .padding()
        .background(Color.annotationBackground)
    }
}

extension Color {
    static var annotationBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
}
