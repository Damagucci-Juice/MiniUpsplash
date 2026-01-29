////
////  ChartView.swift
////  MiniUpsplash
////
////  Created by Gucci on 1/29/26.
////

import SwiftUI
import Charts

struct TrendAnnotationView: View {
    let values: [ValueInfo]
    let date: String
    let valueData: Int

    func foo() {
        var foo: [Int] = [0,0]
        foo.removeLast()
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(date)
                .font(.headline)
            Divider()
            ForEach(values, id: \.self.id) { origin in
                Text(NumberManager.shared.convert(origin.value))
            }
        }
        .padding()
        .background(Color.annotationBackground)
    }
}



struct ChartView: View {
    @State private var selectedDate: String?
    let historical: [ValueInfo]

    var body: some View {
        Chart {
            ForEach(historical) { value in
                AreaMark(
                    x: .value("Day", value.date),
                    y: .value("Value", value.value)
                )
                .interpolationMethod(.catmullRom) // 곡선을 더 부드럽게
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .blue.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            if let selectedDate {
                RuleMark(x: .value("Selected", selectedDate))
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5])) // 점선으로 세련되게
                    .annotation(position: .automatic, alignment: .center) {
                        // 현재 날짜의 데이터만 전달하도록 필터링 추천
                        TrendAnnotationView(values: historical.filter { $0.date == selectedDate },
                                            date: selectedDate,
                                            valueData: 0)
                    }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        updateSelectedDate(at: location, proxy: proxy)
                    }
            }
        }
    }

    private func updateSelectedDate(at location: CGPoint, proxy: ChartProxy) {
        // 탭한 위치에서 가장 가까운 x축 값을 찾음
        guard let date: String = proxy.value(atX: location.x) else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedDate == date {
                selectedDate = nil
            } else {
                selectedDate = date
                // 햅틱 피드백 추가 (iOS 전용)
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
            }
        }
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

#Preview {
    let mockData = [
        ValueInfo(date: "2025-01-11", value: 1),
        ValueInfo(date: "2025-02-09", value: 21),
        ValueInfo(date: "2025-02-10", value: 304),
        ValueInfo(date: "2025-02-13", value: 20),
    ]

    ChartView(historical: mockData)
}
