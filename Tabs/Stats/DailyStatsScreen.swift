////
//  DailyStatsScreen.swift
//  Tomodoro
//
//  Created by Parham Karbasi on 18/10/25.
//

import SwiftUI
import Foundation
import Charts

struct DailyStatsScreen: View {
    @ObservedObject var vm: StatsViewModel
    @State private var hoveredDay: Date?
    
    // list vertical spacing tweak if needed
    private let listTopNudge: CGFloat = 12
    
    // Precomputed data for chart
    private var anchors: [Date] { vm.last7Days }            // 7 days (oldest → newest)
    private var data: [DailyTotal] { vm.dailyTotalsLast7 }  // totals (zeros allowed)
    private var average: Double {
        guard !anchors.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.totalMinutes }
        return Double(total) / Double(anchors.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                chartSection
                listSection
            }
            .padding(.top, 16)
        }
        .contentMargins(.bottom, 0, for: .scrollContent)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(AppTheme.canvas)
    }
    
    // MARK: - CHART SECTION
    @ViewBuilder
    private var chartSection: some View {
        if let firstDay = anchors.first, let lastDay = anchors.last {
            let halfDay: TimeInterval = 60 * 60 * 12
            let domain: ClosedRange<Date> =
            firstDay.addingTimeInterval(-halfDay) ... lastDay.addingTimeInterval(halfDay)
            
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.clear)
                .overlay {
                    Chart {
                        // Bars
                        ForEach(data, id: \.day) { item in
                            BarMark(
                                x: .value("Day", item.day, unit: .day),
                                y: .value("Minutes", max(1, item.totalMinutes))
                            )
                            .foregroundStyle(AppTheme.bar)
                            .cornerRadius(8)
                        }
                        
                        // Average guide + bubble
                        RuleMark(y: .value("Average", average))
                            .foregroundStyle(Color.gray.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .top, alignment: .leading) {
                                CalloutTag(
                                    text: "avg \(Int(average.rounded())) min",
                                    textColor: AppTheme.textSecondary,
                                    baseOpacity: 1.0
                                )
                                .font(.caption2)
                            }
                        
                        // Selection callout
                        if let h = hoveredDay,
                           let hit = data.first(where: { Calendar.current.isDate($0.day, inSameDayAs: h) }) {
                            RuleMark(x: .value("Selected Day", h))
                                .foregroundStyle(AppTheme.bar.opacity(0.35))
                            
                            PointMark(
                                x: .value("Day", hit.day, unit: .day),
                                y: .value("Minutes", max(1, hit.totalMinutes))
                            )
                            .annotation(position: .top) {
                                let dayStr = hit.day.formatted(.dateTime.weekday(.abbreviated))
                                CalloutTag(
                                    text: "\(dayStr) · \(hit.totalMinutes) min",
                                    textColor: .primary,
                                    baseOpacity: 1.0
                                )
                                .monospacedDigit()
                            }
                        }
                    }
                    .chartXScale(
                        domain: domain,
                        range: .plotDimension(startPadding: -20, endPadding: 18)
                    )
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: anchors) { v in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel {
                                if let d = v.as(Date.self) {
                                    Text(d, format: .dateTime.weekday(.narrow))
                                        .font(.system(size: 12, weight: .black))
                                        .italic()
                                        .offset(x: 12)
                                        .offset(y: 6)
                                }
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            Rectangle().fill(.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let plotFrame = geo[proxy.plotAreaFrame]
                                            let xInPlot = value.location.x - plotFrame.origin.x
                                            guard xInPlot >= 0, xInPlot <= proxy.plotAreaSize.width else { return }
                                            if let date: Date = proxy.value(atX: xInPlot) {
                                                if let nearest = anchors.min(by: {
                                                    abs($0.timeIntervalSince1970 - date.timeIntervalSince1970) <
                                                        abs($1.timeIntervalSince1970 - date.timeIntervalSince1970)
                                                }) {
                                                    hoveredDay = nearest
                                                }
                                            }
                                        }
                                )
                        }
                    }
                    .transaction { $0.animation = .easeOut(duration: 0.15) }
                    .padding(.horizontal, 12)
                }
                .frame(height: 240)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - LIST (clear, card-per-day style)
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(vm.sessionsGroupedByDay, id: \.day) { day, items in
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Day header
                    HStack {
                        Text(day, format: .dateTime.weekday(.wide).day().month())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                        Spacer()
                        let totalMin = items.reduce(0) { $0 + $1.minutes }
                        Text("\(totalMin) min")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal, 12)
                    
                    // Sessions block
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, session in
                            HStack {
                                // Title now uses the app background color (beige) instead of orange
                                Text("Session \(index + 1)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(session.minutes) min")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .monospacedDigit()
                            }
                            // more vertical padding between rows
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            
                            // a touch thicker + more visible divider
                            if index < items.count - 1 {
                                Rectangle()
                                    .fill(AppTheme.divider.opacity(0.95))
                                    .frame(height: 1)            // slightly thicker than default
                                    .padding(.leading, 12)       // keep the title visually grouped
                            }
                        }
                    }
                    .background(.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // less curved
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.top, listTopNudge)
        .padding(.bottom, 100) // space for dots/tab bar overlay
    }
    
    // MARK: - Tooltip (glass look + visible text)
    struct CalloutTag: View {
        var text: String
        var textColor: Color = .primary
        var baseOpacity: Double = 0.95
        
        var body: some View {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    ZStack {
                        Capsule().fill(Color(.systemBackground).opacity(baseOpacity))
                        Capsule().fill(.ultraThinMaterial)
                    }
                )
                .foregroundColor(textColor)
                .compositingGroup()
                .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                .zIndex(1)
        }
    }
}
