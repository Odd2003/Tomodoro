//
//  PomoLandView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//
import SwiftUI
import SwiftData
import WebKit

struct PomoLandView: View {
    
    @Environment(\.modelContext) var context
    @Query var stats: [GameStats]
    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    
    var body: some View {
        
        ZStack {
            
            Color(red: 0.494, green: 0.788, blue: 0.286).ignoresSafeArea()
            
            ForEach(0..<(stats.first?.characterCount ?? 0), id:\.self) {_ in
                
                let x: CGFloat = CGFloat.random(in: 15...370)
                let y: CGFloat = CGFloat.random(in: 15...725)
                let pos: CGPoint = CGPoint(x: x, y: y)
               
                
                Image("TomatoChar").resizable().frame(width: 30, height: 30).position(pos)
                
                
            }
            ForEach(0..<(stats.first?.goldCharCount ?? 0), id:\.self) {_ in
                
                let x: CGFloat = CGFloat.random(in: 15...370)
                let y: CGFloat = CGFloat.random(in: 15...725)
                let pos: CGPoint = CGPoint(x: x, y: y)
                
                Image("TomatoCharGold").resizable().frame(width: 30, height: 30).position(pos)
                
            }
            
            Button("Add character") {
                addCharacter()
            }.buttonStyle(GlassButtonStyle()).position(x: 200, y: 675)
            
        }.scaleEffect(zoom).offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture().onChanged({ value in
                        
                        zoom = min(max(value, 1.0), 5.0)
                        
                        if(offset.width > (zoom - 1.0) * 200) {
                            offset = CGSize(width: (zoom - 1.0) * 200, height: offset.height)
                        } else if(offset.width < -(zoom - 1.0) * 200) {
                            offset = CGSize(width: -(zoom - 1.0) * 200, height: offset.height)
                        }
                        
                        if(offset.height > (zoom - 1.0) * 300) {
                            offset = CGSize(width: offset.width, height: (zoom - 1.0) * 300)
                        } else if(offset.height < -(zoom - 1.0) * 300) {
                            offset = CGSize(width: offset.width, height: -(zoom - 1.0) * 300)
                        }
                        
                    }
                                                
                    )
                    .onEnded(
                        {_ in
                            lastZoom = zoom
                        }
                    ),
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            
                            if(offset.width > (zoom - 1.0) * 175) {
                                offset = CGSize(width: (zoom - 1.0) * 175, height: offset.height)
                            } else if(offset.width < -(zoom - 1.0) * 175) {
                                offset = CGSize(width: -(zoom - 1.0) * 175, height: offset.height)
                            }
                            
                            if(offset.height > (zoom - 1.0) * 350) {
                                offset = CGSize(width: offset.width, height: (zoom - 1.0) * 350)
                            } else if(offset.height < -(zoom - 1.0) * 350) {
                                offset = CGSize(width: offset.width, height: -(zoom - 1.0) * 350)
                            }
                            
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                    
                )
            )
            .animation(.spring(), value: zoom)
            .animation(.spring(), value: offset)
        
    }
    
    func addCharacter() {
        if let existing = stats.first {
            existing.characterCount += 1
            
            if(existing.characterCount == 5) {
                existing.goldCharCount += 1
                existing.characterCount = 0
            }
            
            try? context.save()
        } else {
            let firstStats: GameStats = GameStats()
            firstStats.characterCount += 1
            context.insert(firstStats)
        }
    }
    
}



#Preview {
    PomoLandView()
        .modelContainer(for: GameStats.self, inMemory: true)
}
