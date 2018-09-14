//
//  ViewController.swift
//  VideoPlayer
//
//  Created by HsinYuLi on 2018/9/14.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!

    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var searchButton: UIButton!
    
    var avPlayer: AVPlayer?
    
    var avPlayerItem: AVPlayerItem!
    
    var avPlayerLayer : AVPlayerLayer!
    
    var caDisplayLink: CADisplayLink!
    
    var sliding: Bool = false
    
    let seekDuration: Float64 = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        timeSlider.value = 0
        
        caDisplayLink = CADisplayLink(target: self, selector: #selector(updateTimes))
        caDisplayLink.add(to: .main, forMode: .defaultRunLoopMode)
        
        setSliderTouchEvents()
    }
    
    @IBAction func searchUrl(_ sender: UIButton) {
        
        guard let urlString = urlTextField.text else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        avPlayerItem = AVPlayerItem(url: url)

        avPlayer = AVPlayer(playerItem: avPlayerItem)
        
        playVideo(playButton)
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        
        guard let player = avPlayer else { return }
        
        avPlayerLayer = AVPlayerLayer(player: player)
        
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
        
        avPlayerLayer.frame = videoView.layer.bounds
        
        videoView.layer.addSublayer(avPlayerLayer!)
        
        playButton.isSelected = !playButton.isSelected
        
        if playButton.isSelected {
            
            player.play()
            
        } else {
            
            player.pause()
        }
    }
    
    @objc func updateTimes() {
        
        guard let player = avPlayer else { return }
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        
        let totalTime = TimeInterval(avPlayerItem.duration.value) / TimeInterval(avPlayerItem.duration.timescale)
        
        currentTimeLabel.text = formatPlayTime(secounds: currentTime)
        
        totalTimeLabel.text = formatPlayTime(secounds: totalTime)
        
        if !sliding {
            timeSlider.value = Float(currentTime / totalTime)
            
            if timeSlider.value == 1 {
                playButton.isSelected = false
            }
        }
    }
    
    func formatPlayTime(secounds: TimeInterval) -> String {
        
        if secounds.isNaN{
            return "00:00"
        }
        
        let secounds = Int(secounds)
        
        let Min = secounds / 60
        
        let Sec = secounds % 60
        
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    func setSliderTouchEvents() {
        
        timeSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        
        timeSlider.addTarget(self, action: #selector(sliderTouchUpOut), for: .touchUpInside)
        
        timeSlider.addTarget(self, action: #selector(sliderTouchUpOut), for: .touchUpOutside)
        
        timeSlider.addTarget(self, action: #selector(sliderTouchUpOut), for: .touchCancel)
    }
    
    @objc func sliderTouchDown() {
        sliding = true
    }
    
    @objc func sliderTouchUpOut() {
        
        guard let player = avPlayer else { return }
        
        guard let cmTime = player.currentItem?.duration else { return }
        
        let duration = timeSlider.value * Float(CMTimeGetSeconds(cmTime))
        
        let seekTime = CMTimeMake(Int64(duration), 1)
        
        player.seek(to: seekTime) { (_) in
            self.sliding = false
        }
    }
    
    @IBAction func switchMuted(_ sender: UIButton) {
        
        guard let player = avPlayer else { return }
        
        player.isMuted = !player.isMuted
        
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func playRewind(_ sender: UIButton) {
        guard let player = avPlayer else { return }

        let currentTime = CMTimeGetSeconds(player.currentTime())
        
        var newTime = currentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        
        let time: CMTime = CMTimeMake(Int64(newTime), 1)
        
        player.seek(to: time)
    }
    
    @IBAction func playForward(_ sender: UIButton) {
        
        guard let player = avPlayer else { return }

        let totalTime = TimeInterval(avPlayerItem.duration.value) / TimeInterval(avPlayerItem.duration.timescale)
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        
        var newTime = currentTime + seekDuration
        
        if newTime > totalTime {
            newTime = totalTime
        }
        
        let time: CMTime = CMTimeMake(Int64(newTime), 1)

        player.seek(to: time)
    }

}

