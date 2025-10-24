//
//  GenreStatsScreen.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

// Tabs/Stats/GenreStatsScreen.swift

//
//  GenreStatsScreen.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

//
//  GenreStatsScreen.swift
//  Tomodoro
//
//  Created by Parham Karbasi on 18/10/25.
//

import SwiftUI
import Charts

struct GenreStatsScreen: View {
    @ObservedObject var vm: StatsViewModel

    // Fixed order so spacing/labels are stable
    private let palette = ["Lo-Fi", "Rock", "White Noise"]

    var body: some View {
        // Build a genre → minutes map from VM
        let dict = Dictionary(uniqueKeysWithValues: vm.genresWithMinutes.map { ($0.genre, $0.minutes) })
        let rows: [(genre: String, minutes: Int)] = palette.map { ($0, dict[$0] ?? 0) }
        let total = rows.reduce(0) { $0 + $1.minutes }
        let average = rows.isEmpty ? 0 : Double(total) / Double(rows.count)
        let yMax = max(1, rows.map(\.minutes).max() ?? 0)

        ScrollView {
            VStack(spacing: 16) {

                // ===== Chart ===================================================
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.clear)
                    .overlay {
                        Chart(rows, id: \.genre) { row in
                            BarMark(
                                x: .value("Genre", row.genre),
                                y: .value("Minutes", row.minutes)
                            )
                            .foregroundStyle(AppTheme.bar)
                            .cornerRadius(8)
                        }
                        // Average guide + readable bubble (not clipped)
                        .overlay {
                            Chart {
                                RuleMark(y: .value("Average", average))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        CalloutTag(
                                            text: "avg \(Int(average.rounded())) min",
                                            textColor: AppTheme.textSecondary,
                                            baseOpacity: 1.0
                                        )
                                        .font(.caption2)
                                        .offset(x: -14) // ← nudge inside the plot so it isn’t cut
                                    }
                            }
                        }
                        .chartYScale(domain: 0...Double(yMax))
                        .chartYAxis(.hidden)
                        .chartXScale(domain: palette) // lock categorical order
                        .chartPlotStyle { plot in
                            plot
                                .padding(.top, 8)
                                .padding(.leading, 16)     // ← extra left room for the bubble
                                .padding(.trailing, 8)
                        }
                        .chartXAxis {
                            AxisMarks(values: palette) { v in
                                AxisGridLine().foregroundStyle(.clear)
                                AxisTick().foregroundStyle(.clear)
                                AxisValueLabel {
                                    if let g = v.as(String.self) {
                                        Text(g)
                                            .font(.system(size: 12, weight: .semibold))
                                            .italic()
                                            .offset(y: 8)
                                            .offset(x: 7)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)   // inner chart padding
                    }
                    .frame(height: 260)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                // ===============================================================

                // ===== Transparent list (no card background) ==================
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(rows, id: \.genre) { row in
                        HStack {
                            Text(row.genre)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.bar)
                            Spacer()
                            Text("\(row.minutes) min")
                                .foregroundStyle(AppTheme.textSecondary)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 48)

                        Divider().overlay(AppTheme.divider)
                            .padding(.leading, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 80) // room for dots + glass tab bar
            }
            .padding(.top, 16)
        }
        .contentMargins(.bottom, 0, for: .scrollContent)
        .ignoresSafeArea(.container, edges: .bottom)   // let it extend under the glass bar
        .background(AppTheme.canvas)
        .preferredColorScheme(.light)
    }
}
