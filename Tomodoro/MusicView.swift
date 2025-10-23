//
//  MusicView.swift
//  Tomodoro
//
//  Created by Rosario d'Antonio on 21/10/25.
//

import SwiftUI
import AVFoundation
var player: AVAudioPlayer?

struct MusicView: View {
    
    var songList: SongList = SongList()
    
    var body: some View {
        
        List {
            ForEach(Genre.allCases, id: \.self) { genre in
                
                Section(header: Text(genre.rawValue).font(.system(size: 30, weight: .bold)).foregroundStyle(.black)) {
                    
                    ForEach(songList.songs) { song in
                        
                        if(song.genre == genre) {
                            HStack {
                                Button {
                                    playSong(name: song.name)
                                } label: {
                                    
                                    let txt = makeText(song: song)
                                    Text(txt)
                                }
                                
                                Spacer()
                                
                                
                            }.foregroundStyle(.black)
                        }
                        
                    }
                }
            }
        }
        .scrollContentBackground(.hidden).background(.milky)
    }
    
}

func makeText(song: Song) -> String {
    let duration: TimeInterval = getSongDuration(name: song.name)
    let minutes = Int(duration)/60
    let seconds = Int(duration) % 60
    
    let formatted = String(format: "%d:%02d", minutes, seconds)
    
    let txt: String = "\(song.name) | \(formatted)"
        
    return txt
}

func playSong(name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

        guard let player = player else { return }

        player.play()

    } catch let error {
        print(error.localizedDescription)
    }
}

func getSongDuration(name: String) -> TimeInterval {
    guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return 0 }

    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

        guard let player = player else { return 0 }

        return player.duration

    } catch let error {
        print(error.localizedDescription)
    }
    
    return 0
}


#Preview {
    MusicView()
}
