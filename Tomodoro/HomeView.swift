//
//  HomeView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

let breakTime: Int = 5
let focusTime: Int = 10

import SwiftUI

struct HomeView: View {
    @State var isRunning: Bool = false

    @State var timeRemaining: Int = focusTime
    @State var isBreak: Bool = false
    @State var isSheetVisible: Bool = false
    @State var timer: Timer?
    
    @State var rating: Int = 5

    var body: some View {
        Color.accent.overlay {
            VStack(spacing: -4) {
                Text(isBreak ? "Break" : "Focus")
                    .foregroundStyle(.white)
                    .font(.system(size: 72))
                    .offset(y: -30)
                    .id(isBreak)
                    .transition(.opacity.combined(with: .scale))

                Image("PomodoroImage")
                    .resizable()
                    .frame(width: 265, height: 300)
                    .overlay {
                        Button {
                            isRunning ? stop() : start()
                        } label: {
                            Image(systemName: isRunning ? "pause.circle" : "play.circle")
                                .font(.system(size: 100))
                                .foregroundStyle(.accent)
                                .offset(y: 20)
                        }
                    }
                
                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .frame(width: 195, alignment: .leading)
                        .foregroundStyle(.white)
                        .font(.system(size: 72))
                        .contentTransition(.numericText(value: Double(timeRemaining)))
                
            }
            .offset(y: -50)
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            Button {
                isSheetVisible.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 28)
                    .foregroundStyle(Material.thin)
                    .frame(height: 76)
                    .shadow(radius: 5, y: 3)
                    .padding(.horizontal, 33)
                    .padding(.bottom)
            }
        }
        .sheet(isPresented: $isSheetVisible) {
            EmptyView()
        }
    }

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                withAnimation {
                    timeRemaining -= 1
                }
            } else {
                stop()
                withAnimation {
                    isBreak.toggle()
                }
                timeRemaining = isBreak ? breakTime : focusTime
                start()
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
    }
}

#Preview {
    ContentView()
}

//                        .background(
//                            Image(systemName: "play.circle")
//                                .font(.system(size: 100))
//                                .foregroundStyle(.black)
//                                .scaleEffect(1.05)
//                        )
