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
    
    @State var progress: Float = 0.0
    
    @Namespace private var namespace

    var body: some View {
        Color.milky.overlay {
            Image("Pattern2")
                .resizable().scaledToFit()
                .opacity(0.3)
            
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
                    // Gray circle
                    Circle()
                        .stroke(lineWidth: 30.0)
                        .opacity(0.3)
                        .foregroundColor(.black)
                    //                            .glassEffect(.regular.tint(.orange))
                    
                    // Orange circle
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 25.0,
                                                   lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.accent)
                    // Ensures the animation starts from 12 o'clock
                        .rotationEffect(Angle(degrees: 270))
                    
                    
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
                
                //                Circle()
                //                    .foregroundColor(.gray)
                //                    .frame(width: 265, height: 300)
                //                    .overlay {
                //                        Button {
                //                            isRunning ? stop() : start()
                //                        } label: {
                //                            Image(systemName: isRunning ? "pause.circle" : "play.circle")
                //                                .font(.system(size: 100))
                //                                .foregroundStyle(.accent)                        }
                //                    }
                
                
                
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
                            
                            Text("Not Playing")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                            
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
                MusicView()
            }.background(.milky)
            
//            NavigationStack {
//                MusicView()
//            }
//            .matchedTransitionSource(id: "zoom", in: namespace)
//            .navigationTransition(.zoom(sourceID: "zoom", in: namespace))
//            .background(.milky)
            
        }
    }

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                withAnimation {
                    timeRemaining -= 1
                    progress = 1 - (Float(timeRemaining) / Float(isBreak ? breakTime : focusTime))
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
