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

    // Fixed order so spacing/labels are stable (adjust if you support more)
    private let palette = ["Lo-Fi", "Rock", "White Noise"]

    var body: some View {
        // genre → minutes map
        let dict = Dictionary(uniqueKeysWithValues: vm.genresWithMinutes.map { ($0.genre, $0.minutes) })
        // rows in fixed order
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
                            .foregroundStyle(AppTheme.bar) // #FF8B65
                            .cornerRadius(8)
                        }
                        // average guide + bubble (match Daily page)
                        .overlay {
                            Chart {
                                RuleMark(y: .value("Average", average))
                                    .foregroundStyle(Color.gray.opacity(0.6))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        CalloutTag(
                                            text: "avg \(Int(average.rounded())) min",
                                            textColor: AppTheme.textSecondary,
                                            baseOpacity: 1.0
                                        )
                                        .font(.caption2)
                                        .offset(x: -14) // nudge left so it doesn’t clip
                                    }
                            }
                        }
                        .chartYScale(domain: 0 ... Double(yMax))
                        .chartYAxis(.hidden)
                        .chartXScale(domain: palette) // lock order
                        .chartPlotStyle { plot in
                            plot.padding(.top, 8).padding(.horizontal, 8)
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
                        .padding(.horizontal, 12)
                    }
                    .frame(height: 260)
                    .padding(.horizontal, 20)

                // ===== List (match Daily page styling) ========================
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                        HStack {
                            // Title color = same as duration (secondary)
                            Text(row.genre)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)

                            Spacer()

                            Text("\(row.minutes) min")
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.textSecondary)
                                .monospacedDigit()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        if index < rows.count - 1 {
                            Rectangle()
                                .fill(AppTheme.divider.opacity(0.95)) // stronger divider
                                .frame(height: 1)
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // less curved
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.bottom, 12) // small bottom space so it can slide under the tab bar
            }
            .padding(.top, 16)
        }
        .background(AppTheme.canvas) // your beige
        .ignoresSafeArea(.container, edges: .bottom) // allow scrolling under tab bar
        .preferredColorScheme(.light)
    }
}
