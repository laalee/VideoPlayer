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
    
    @IBOutlet weak var rewindButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var noVideoLabel: UILabel!
    
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
        
        setButtonTemplateImage()
        
        timeSlider.value = 0
        
        caDisplayLink = CADisplayLink(target: self, selector: #selector(updateTimes))
        caDisplayLink.add(to: .main, forMode: .defaultRunLoopMode)
        
        setSliderTouchEvents()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { context in
            
            if UIApplication.shared.statusBarOrientation.isLandscape {
                
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                
                self.videoView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
                self.noVideoLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                self.setButtonColor(with: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                
                self.setLabelColor(with: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                
            } else {
                
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                
                self.videoView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                self.noVideoLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                
                self.setButtonColor(with: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                
                self.setLabelColor(with: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            }
        })

        fullScreenButton.isSelected = !fullScreenButton.isSelected
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            
            self.avPlayerLayer.frame.size = self.videoView.frame.size
        })
    }
    
    
    
    @IBAction func searchUrl(_ sender: UIButton) {
        
        guard let urlString = urlTextField.text else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        avPlayerItem = AVPlayerItem(url: url)
        
        avPlayerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)

        avPlayer = AVPlayer(playerItem: avPlayerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let playerItem = object as? AVPlayerItem else { return }
        
        if keyPath == "status"{

            if playerItem.status == AVPlayerItemStatus.readyToPlay {
  
                if !noVideoLabel.isHidden {
                    
                    timeSlider.value = 0
                    
                    playVideo(playButton)
                    
                    noVideoLabel.isHidden = true
                }
            } else if playerItem.status == AVPlayerItemStatus.failed {
                
                noVideoLabel.isHidden = false
                
            } else {
                
                print("Unknown error")
            }
        }
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        
        guard let player = avPlayer else { return }
        
        avPlayerLayer = AVPlayerLayer(player: player)
        
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
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
    
    @IBAction func switchOrientation(_ sender: UIButton) {
        
        print("switchOrientation")
        
        UIView.setAnimationsEnabled(false)

        if UIApplication.shared.statusBarOrientation.isLandscape {

            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

        } else {
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    func setButtonTemplateImage() {
        
        var templateImage = #imageLiteral(resourceName: "btn_play").withRenderingMode(.alwaysTemplate)
        playButton.setImage(templateImage, for: .normal)
        
        templateImage = #imageLiteral(resourceName: "btn_stop").withRenderingMode(.alwaysTemplate)
        playButton.setImage(templateImage, for: .selected)
        
        templateImage = #imageLiteral(resourceName: "btn_play_rewind").withRenderingMode(.alwaysTemplate)
        rewindButton.setImage(templateImage, for: .normal)
        
        templateImage = #imageLiteral(resourceName: "btn_play_forward").withRenderingMode(.alwaysTemplate)
        forwardButton.setImage(templateImage, for: .normal)

        templateImage = #imageLiteral(resourceName: "btn_volume_up").withRenderingMode(.alwaysTemplate)
        muteButton.setImage(templateImage, for: .normal)
        
        templateImage = #imageLiteral(resourceName: "btn_volume_off").withRenderingMode(.alwaysTemplate)
        muteButton.setImage(templateImage, for: .selected)

        templateImage = #imageLiteral(resourceName: "btn_fullScreen").withRenderingMode(.alwaysTemplate)
        fullScreenButton.setImage(templateImage, for: .normal)
        
        templateImage = #imageLiteral(resourceName: "btn_fullScreen_exit").withRenderingMode(.alwaysTemplate)
        fullScreenButton.setImage(templateImage, for: .selected)
        
        setButtonColor(with: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    func setButtonColor(with color: UIColor) {
        
        playButton.imageView?.tintColor = color
        
        rewindButton.imageView?.tintColor = color
        
        forwardButton.imageView?.tintColor = color
        
        muteButton.imageView?.tintColor = color
        
        fullScreenButton.imageView?.tintColor = color
    }
    
    func setLabelColor(with color: UIColor) {
        
        currentTimeLabel.textColor = color
        
        totalTimeLabel.textColor = color
    }

}

