//
//  AudioService.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 23/10/25.
//

import Foundation
import AVFoundation

@Observable
class AudioService {
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var currentSong: String?
    
    private var player: AVAudioPlayer?
    private var timeObserver: Timer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playSong(name: String) {
        // If the same song is requested and we already have a player, seek to saved time and play.
        if let player = player, currentSong == name {
            player.currentTime = currentTime
            player.play()
            isPlaying = true
            startTimeObserver()
            return
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Song not found: \(name)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.prepareToPlay()
            
            // If switching to a new song, reset position.
            if currentSong != name {
                currentTime = 0
            }
            player.currentTime = currentTime
            player.play()
            
            currentSong = name
            duration = player.duration
            isPlaying = true
            
            startTimeObserver()
            
        } catch {
            print("Failed to play song: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        player?.pause()
        // Persist currentTime on pause
        if let player = player {
            currentTime = player.currentTime
        }
        isPlaying = false
        stopTimeObserver()
    }
    
    func resume() {
        // Resume from saved currentTime
        if let player = player {
            player.currentTime = currentTime
            player.play()
            isPlaying = true
            startTimeObserver()
        } else if let song = currentSong {
            // In case player was released, recreate and resume
            playSong(name: song)
        }
    }
    
    func stop() {
        // Persist currentTime before stopping so resume can continue
        if let player = player {
            currentTime = player.currentTime
        }
        player?.stop()
        player = nil
        isPlaying = false
        // Do not reset currentSong or currentTime so we can resume later
        stopTimeObserver()
    }
    
    func getSongDuration(name: String) -> TimeInterval {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            return 0
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            return audioPlayer.duration
        } catch {
            print("Failed to get song duration: \(error.localizedDescription)")
            return 0
        }
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    // MARK: - Time Observer
    
    private func startTimeObserver() {
        stopTimeObserver()
        
        timeObserver = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
            
            if !player.isPlaying && self.isPlaying {
                self.isPlaying = false
                self.stopTimeObserver()
            }
        }
    }
    
    private func stopTimeObserver() {
        timeObserver?.invalidate()
        timeObserver = nil
    }
    
    deinit {
        stopTimeObserver()
    }
}

