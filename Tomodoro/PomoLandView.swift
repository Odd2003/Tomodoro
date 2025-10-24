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
            
            Color(red: 0.554, green: 0.72, blue: 0.286).ignoresSafeArea()
            
            initIsland()
            
            ForEach(0..<(stats.first?.characterCount ?? 0), id: \.self) {_ in
                
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
            
        }
        .scaleEffect(zoom).offset(offset)
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
    
    
    
    func initIsland() -> some View {
        
        let bushPositions: [CGPoint] = [
            CGPoint(x: 42,  y: 687),
            CGPoint(x: 358, y: 112),
            CGPoint(x: 219, y: 703),
            CGPoint(x: 91,  y: 341),
            CGPoint(x: 177, y: 496),
            CGPoint(x: 366, y: 270),
            CGPoint(x: 144, y: 71),
            CGPoint(x: 305, y: 657),
            CGPoint(x: 35,  y: 203),
            CGPoint(x: 257, y: 592),
            CGPoint(x: 72,  y: 645),
            CGPoint(x: 341, y: 188),
            CGPoint(x: 298, y: 714),
            CGPoint(x: 119, y: 472),
        ]
        let treePositions: [CGPoint] = [
            CGPoint(x: 82,  y: 705),
            CGPoint(x: 347, y: 412),
            CGPoint(x: 291, y: 156),
            CGPoint(x: 121, y: 523),
            CGPoint(x: 220, y: 308),
            CGPoint(x: 59,  y: 98)
        ]
        
        return ZStack {
            ForEach(bushPositions, id: \.self) {
                pos in
                Image("Bush").resizable().frame(width: 40, height: 40).position(pos)
            }
            ForEach(treePositions, id: \.self) {
                pos in
                Image("Tree").resizable().frame(width: 60, height: 60).position(pos)
            }
        }
    }
    
}



#Preview {
    PomoLandView()
        .modelContainer(for: GameStats.self, inMemory: true)
}
