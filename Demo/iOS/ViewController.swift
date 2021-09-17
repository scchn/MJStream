//
//  ViewController.swift
//  iOS
//
//  Created by scchn on 2021/9/17.
//

import UIKit

let videoURL = URL(string: "https://cctvc.freeway.gov.tw/abs2mjpg/bmjpg?camera=105")!

class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private let stream = MJStream()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.tintColor = .white
        playButton.backgroundColor = .systemBlue
        playButton.layer.cornerRadius = 6
        
        imageView.backgroundColor = .lightGray
        
        stream.frameHandler = { [weak self] image in
            self?.imageView.image = image
        }
        
        stream.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .playing:
                self.playButton.setTitle("Stop", for: .normal)
                
            default:
                self.playButton.setTitle("Play", for: .normal)
                self.imageView.image = nil
            }
        }
    }

    @IBAction func playButtonAction(_ sender: Any) {
        guard stream.state == .stopped else { return stream.stop() }
        
        let alert = UIAlertController(title: "Loading...", message: nil, preferredStyle: .alert)
        
        alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
            self.stream.stop()
        })
        
        present(alert, animated: true)
        
        stream.play(url: videoURL, timeoutInterval: 3) { ok in
            alert.dismiss(animated: true) {
                guard !ok else { return }
                let alert = UIAlertController(title: "Connection failed", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
}

