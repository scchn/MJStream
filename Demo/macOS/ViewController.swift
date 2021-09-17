//
//  ViewController.swift
//  macOS
//
//  Created by scchn on 2021/9/17.
//

import Cocoa

let videoURL = URL(string: "https://cctvc.freeway.gov.tw/abs2mjpg/bmjpg?camera=105")!

class ViewController: NSViewController {

    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var previewView: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    private let stream = MJStream()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.wantsLayer = true
        previewView.layer?.backgroundColor = NSColor.lightGray.cgColor
        previewView.layer?.contentsGravity = .resizeAspect
        
        stream.frameHandler = { [weak self] image in
            self?.updatePreviewView(image: image)
        }
        
        stream.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .stopped:
                self.playButton.title = "Play"
                self.progressIndicator.isHidden = true
                self.progressIndicator.stopAnimation(nil)
                self.updatePreviewView(image: nil)
            case .loading:
                self.playButton.title = "Loading..."
                self.progressIndicator.isHidden = false
                self.progressIndicator.startAnimation(nil)
            case .playing:
                self.playButton.title = "Stop"
                self.progressIndicator.isHidden = true
                self.progressIndicator.stopAnimation(nil)
            }
        }
    }

    private func updatePreviewView(image: NSImage?) {
        previewView.layer?.contents = image
    }

    @IBAction func play(_ sender: Any) {
        switch stream.state {
        case .stopped:
            stream.play(url: videoURL, timeoutInterval: 3) { success in
                print(success)
            }
        case .loading, .playing:
            stream.stop()
        }
    }

}
