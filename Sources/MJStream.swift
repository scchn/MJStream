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
public typealias Image = NSImage
#else
public typealias Image = UIImage
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
    
    private(set)
    public var url: URL?
    
    @objc dynamic private(set)
    public var state: State = .stopped {
        didSet {
            guard state != oldValue else { return }
            stateUpdateHandler?(state)
        }
    }
    
    public var stateUpdateHandler: ((State) -> Void)? {
        didSet {
            guard let handler = stateUpdateHandler else { return }
            handler(state)
        }
    }
    
    public var frameHandler: ((Image) -> Void)?
    
    public override init() {
        super.init()
        
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    public func play(url: URL, timeoutInterval: TimeInterval = 60) {
        if state != .stopped {
            stop()
        }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        let task = session.dataTask(with: request)
        
        task.resume()
        
        self.url = url
        state = .loading
        dataTask = task
    }
    
    private func cleanup() {
        dataTask?.cancel()
        dataTask = nil
        receivedData.removeAll()
        state = .stopped
    }
    
    public func stop() {
        guard state != .stopped else { return }
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
        }
        
        if let handler = frameHandler, let image = Image(data: receivedData) {
            handler(image)
        }
        
        receivedData.removeAll()
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if task == dataTask {
            cleanup()
        }
    }
    
}

