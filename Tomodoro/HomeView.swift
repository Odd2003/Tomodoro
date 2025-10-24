//
//  HomeView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

let breakTime: Int = 5
let focusTime: Int = 10

import SwiftUI
import SwiftData

struct HomeView: View {
    @State var isRunning: Bool = false

    @State var timeRemaining: Int = focusTime
    @State var isBreak: Bool = false
    @State var isSheetVisible: Bool = false
    @State var timer: Timer?
    
    @State var rating: Int = 5
    @State var progress: Float = 0.0
    
    @Namespace private var namespace
    
    var songPlayer: AudioService
    
    // Game stats (SwiftData)
    @Environment(\.modelContext) var context
    @Query var stats: [GameStats]

    // 👇 NEW: Shared statistics store (injected from ContentView)
    @EnvironmentObject private var store: AppStatsStore

    var body: some View {
        Color.milky.overlay {
            Image("Pattern2")
                .resizable().scaledToFit()
                .opacity(0.2)
            
            VStack(spacing: 0) {
                Text(isBreak ? "Break" : "Focus")
                    .foregroundStyle(.black)
                    .font(.system(size: 50))
                    .id(isBreak)
                    .padding(.horizontal, 16)
                    .glassEffect(in: .rect(cornerRadius: 16.0))
                    .transition(.opacity.combined(with: .scale))
                    .offset(y: -50)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 30.0)
                        .opacity(0.3)
                        .foregroundColor(.black)
                    
                    // Orange progress ring
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(
                            style: StrokeStyle(lineWidth: 25.0, lineCap: .round, lineJoin: .round)
                        )
                        .foregroundColor(Color.accent)
                        .rotationEffect(Angle(degrees: 270)) // start at 12 o’clock
                    
                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .foregroundStyle(.black)
                        .font(.system(size: 40))
                        .padding(.horizontal, 10)
                        .contentTransition(.numericText(value: Double(timeRemaining)))
                        .glassEffect(in: .rect(cornerRadius: 16.0))
                        .padding()
                }
                .padding(.horizontal, 60)
                
                Button(isRunning ? "Pause" : "Start") {
                    withAnimation {
                        isRunning ? stop() : start()
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 30))
                .buttonStyle(.glass(.regular.tint(.accent).interactive()))
                .offset(y: 50)
                
            }
            .offset(y: -50)
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            Button {
                isSheetVisible.toggle()
            } label: {
                ZStack {
                    HStack {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundColor(Color("Gray"))
                                
                                Image("Music")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .offset(x: -1)
                            }
                            .frame(width: 30, height: 30)
                            
                            Text(songPlayer.currentSong ?? "Not Playing")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                if songPlayer.isPlaying {
                                    songPlayer.pause()
                                } else {
                                    if let current = songPlayer.currentSong {
                                        songPlayer.playSong(name: current)
                                    } else {
                                        songPlayer.resume() // no-op if nothing loaded
                                    }
                                }
                            } label: {
                                Image(systemName: songPlayer.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "forward.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                                .opacity(0.5)
                        }
                        .frame(width: 75)
                    }
                    .padding(.horizontal, 25)
                }
                .foregroundStyle(.white)
                .frame(height: 52)
                .glassEffect()
                .padding(.horizontal, 18)
                .matchedTransitionSource(id: "zoom", in: namespace)
            }
            .offset(y: -10)
        }
        .sheet(isPresented: $isSheetVisible) {
            VStack(alignment: .trailing) {
                Button {
                    isSheetVisible.toggle()
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(Color(.black))
                        .font(.system(size: 24))
                }
                .padding(.top, 30)
                .padding(.trailing, 30)
                MusicView(songPlayer: songPlayer)
            }
            .background(.milky)
        }
    }

    // MARK: - Timer control
    
    func start() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                withAnimation {
                    timeRemaining -= 1
                    progress = 1 - (Float(timeRemaining) / Float(isBreak ? breakTime : focusTime))
                }
            } else {
                // Capture what segment we just completed
                let finishedSegmentSeconds = isBreak ? breakTime : focusTime

                stop()
                
                if !isBreak {
                    // We finished a FOCUS block → log it to Statistics
                    let genre = currentGenreName()
                    Task { @MainActor in
                        store.logCompletedSession(
                            durationSeconds: finishedSegmentSeconds,
                            genre: genre,
                            endedAt: Date()
                        )
                    }
                    addCharacter() // keep your SwiftData reward logic
                }
                
                withAnimation { isBreak.toggle() }
                timeRemaining = isBreak ? breakTime : focusTime
                progress = 0
                start()
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Helpers

    /// Resolve a user-facing genre name from the currently selected song.
    private func currentGenreName() -> String {
        if let name = songPlayer.currentSong {
            let list = SongList()
            if let g = list.songs.first(where: { $0.name == name })?.genre.rawValue {
                return g
            }
        }
        // Fallback if no song is selected
        return "Lo-Fi"
    }

    func addCharacter() {
        if let existing = stats.first {
            existing.characterCount += 1
            if existing.characterCount == 5 {
                existing.goldCharCount += 1
                existing.characterCount = 0
            }
            try? context.save()
        } else {
            let firstStats = GameStats()
            firstStats.characterCount += 1
            context.insert(firstStats)
            try? context.save()
        }
    }
}

#Preview {
    ContentView().modelContainer(for: GameStats.self, inMemory: true)
}
