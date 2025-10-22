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
    @State private var hoveredDay: Date?      // currently tapped / dragged day

    private let listTopNudge: CGFloat = 30    // adjust only the list position

    // MARK: - Precomputed data
    private var anchors: [Date] { vm.last7Days }            // 7 days (oldest → newest)
    private var data: [DailyTotal] { vm.dailyTotalsLast7 }  // totals (zeros allowed)
    private var average: Double {
        guard !anchors.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.totalMinutes }
        return Double(total) / Double(anchors.count)
    }

    // MARK: - BODY
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                chartSection
                listSection
                Color.clear.frame(height: 70)
            }
            .padding(.top, 16)
        }
        .contentMargins(.bottom, -30, for: .scrollContent)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 10) }
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

                        // Average line + bubble
                        RuleMark(y: .value("Average", average))
                            .foregroundStyle(.secondary)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .top, alignment: .leading) {
                                CalloutTag(
                                    text: "avg \(Int(average.rounded())) min",
                                    textColor: AppTheme.textSecondary,
                                    baseOpacity: 1.0
                                )
                                .font(.caption2)
                            }

                        // Selection guide + bubble
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

                    // Overlay gesture for tap/drag detection
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            Rectangle()
                                .fill(.clear)
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
                                        .onEnded { _ in
                                            // keep selected, or uncomment below to clear
                                            // hoveredDay = nil
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

    // MARK: - LIST SECTION
    private var listSection: some View {
        StatsCardContent {
            if vm.sessions.isEmpty {
                Text("No sessions yet. Start a timer on the main tab.")
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.sessionsGroupedByDay, id: \.day) { day, items in
                        // Day header
                        HStack {
                            Text(day, format: .dateTime.weekday(.wide).day().month())
                                .font(.system(size: 14, weight: .semibold))
                                .offset(x: -8)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Sessions for that day — numbered
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, s in
                            HStack {
                                Text("Session \(idx + 1)")
                                    .foregroundStyle(AppTheme.bar)

                                Spacer()

                                Text("\(s.minutes) min")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 44)

                            Divider().overlay(AppTheme.divider)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, listTopNudge)
        .padding(.bottom, 5)
    }
}

//
// MARK: - Tooltip (glass look + visible text)
//
struct CalloutTag: View {
    var text: String
    var textColor: Color = .primary
    var baseOpacity: Double = 0.95

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(                       // Both layers *behind* text
                ZStack {
                    Capsule().fill(Color(.systemBackground).opacity(baseOpacity))
                    Capsule().fill(.ultraThinMaterial)
                }
            )
            .foregroundColor(textColor)         // Explicit text color
            .compositingGroup()
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .zIndex(1)
    }
}

//
// MARK: - Shared card container
//
struct StatsCardContent<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}
