//
//  MJStream.swift
//  
//
//  Created by scchn on 2021/9/16.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias MJImage = NSImage
#else
public typealias MJImage = UIImage
#endif

extension MJStream {
    
    @objc public enum State: Int {
        case stopped
        case loading
        case playing
    }
    
}

public class MJStream: NSObject {
    
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?
    private var receivedData = Data()
    private var playCompletionHandler: ((Bool) -> Void)?
    
    public let timeoutInterval: TimeInterval
    
    private(set)
    public var videoURL: URL?
    
    @objc dynamic private(set)
    public var state: State = .stopped {
        didSet {
            guard state != oldValue else { return }
            stateUpdateHandler?(state)
        }
    }
    
    public var stateUpdateHandler: ((State) -> Void)? {
        didSet { stateUpdateHandler?(state) }
    }
    public var imageReceiveHandler: ((MJImage) -> Void)?
    public var disconnectionHandler: (() -> Void)?
    
    public init(timeoutInterval: TimeInterval = 60) {
        self.timeoutInterval = timeoutInterval
        
        super.init()
        
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    // MARK: - Play
    
    public func play(videoURL url: URL, _ completionHandler: ((Bool) -> Void)? = nil) {
        if state != .stopped {
            stop()
        }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        let task = session.dataTask(with: request)
        
        task.resume()
        
        dataTask = task
        receivedData.removeAll()
        playCompletionHandler = completionHandler
        videoURL = url
        state = .loading
    }
    
    public func play(_ completionHandler: ((Bool) -> Void)? = nil) {
        guard let videoURL = videoURL else {
            completionHandler?(false)
            return
        }
        
        play(videoURL: videoURL, completionHandler)
    }
    
    // MARK: - Stop
    
    private func cleanup() {
        let failed = state == .loading
        
        dataTask?.cancel()
        dataTask = nil
        receivedData.removeAll()
        state = .stopped
        
        if failed, let handler = playCompletionHandler {
            handler(false)
            playCompletionHandler = nil
        }
    }
    
    public func stop() {
        guard state != .stopped else {
            return
        }
        
        cleanup()
    }
    
}

extension MJStream: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(contentsOf: data)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if state != .playing {
            state = .playing
            playCompletionHandler?(true)
            playCompletionHandler = nil
        }
        
        if let handler = imageReceiveHandler, let image = MJImage(data: receivedData) {
            handler(image)
        }
        
        receivedData.removeAll()
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if task == dataTask {
            cleanup()
            disconnectionHandler?()
        }
    }
    
}

