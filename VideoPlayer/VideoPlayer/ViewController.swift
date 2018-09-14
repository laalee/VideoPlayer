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
    
    @IBOutlet weak var videoView: UIView!
    
    var avPlayer: AVPlayer?
    
    var avPlayerLayer : AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.isSelected = false
    }
    
    @IBAction func searchUrl(_ sender: UIButton) {
        
        guard let urlString = urlTextField.text else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        avPlayer = AVPlayer(url: url)
        
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

}

