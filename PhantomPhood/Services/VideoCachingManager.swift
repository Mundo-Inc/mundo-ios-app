//
//  VideoCachingManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/2/24.
//

import Foundation
import AVFoundation

/// Manages the caching of video files to disk.
final class VideoCachingManager {
    static let daysToLeepCachedFiles: Int = 10
    static let maxItemsInQueue: Int = 15
    static let shared = VideoCachingManager()
    
    private let fileManager = FileManager.default
    private let videoCacheDirectory: URL
    
    private var isCaching: Bool = false
    private let queue = DispatchQueue(label: "ai.phantomphood.VideoCachingManager", attributes: .concurrent)
    private var cachingQueue: [URL] = [] {
        didSet {
            if !isCaching, let first = cachingQueue.first {
                Task {
                    await startCachingAsset(first)
                }
            }
        }
    }
    
    private init() {
        let baseCacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        videoCacheDirectory = baseCacheDirectory.appendingPathComponent("VideoCache", isDirectory: true)
        
        // Create the video cache directory if it does not exist
        if !fileManager.fileExists(atPath: videoCacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: videoCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating video cache directory: \(error)")
            }
        }
    }
    
    // MARK: - Methods
    
    /// Retrieves a cached asset for a given URL, or initializes a streaming asset if not available.
    /// - Parameters:
    ///   - url: The URL of the video to retrieve.
    ///   - priority: The priority for caching this video if it is not already cached.
    /// - Returns: An AVAsset that can be used to play the video.
    func getAsset(for url: URL, priority: CachingPriority) -> AVAsset {
        let localURL = fileURL(for: url)
        if fileManager.fileExists(atPath: localURL.path) {
            return AVURLAsset(url: localURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        }
        
        addToQueue(url, priority: priority)
        
        // Use AVURLAsset for streaming
        return AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    }
    
    /// Updates the modification date of the cached file for the specified URL, if the file exists.
    /// - Parameter url: The URL of the file whose modification date should be updated.
    func touchFile(at url: URL) {
        let localURL = fileURL(for: url)
        
        guard fileManager.fileExists(atPath: localURL.path) else { return }
        
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: localURL.path)
    }
    
    // Clear disk cache
    func clearDiskCache() async throws {
        let contents = try fileManager.contentsOfDirectory(at: videoCacheDirectory, includingPropertiesForKeys: nil, options: [])
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Clears all cached files that are older than default timeframe to free up disk space.
    /// This method checks each file's creation date and deletes it if it's older than default timeframe.
    func clearOldCacheFiles() async throws {
        let contents = try fileManager.contentsOfDirectory(at: videoCacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: [])
        let timeframe = Calendar.current.date(byAdding: .day, value: -Self.daysToLeepCachedFiles, to: Date())!
        
        for fileURL in contents {
            let fileAttributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = fileAttributes[.modificationDate] as? Date {
                if modificationDate < timeframe {
                    try fileManager.removeItem(at: fileURL)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    /// Adds a video URL to the caching queue with specified priority.
    /// - Parameters:
    ///   - url: The URL of the video to cache.
    ///   - postition: The priority of the caching operation, either high or low.
    /// - If the URL is already in the queue, it will be moved to the specified position
    /// - If the URL is already cached, it will not be added to the queue
    /// - If the queue is full, the last item will be removed
    private func addToQueue(_ url: URL, priority: CachingPriority) {
        queue.async(flags: .barrier) {
            // Check if the url has already been cached
            guard !FileManager.default.fileExists(atPath: self.fileURL(for: url).path) else {
                return
            }
            
            // if already in queue, set the proper position
            if let index = self.cachingQueue.firstIndex(of: url) {
                self.cachingQueue.remove(at: index)
            }
            
            // Check if the queue is full and remove the last item
            if self.cachingQueue.count >= Self.maxItemsInQueue {
                self.cachingQueue.removeLast()
            }
            
            switch priority {
            case .high:
                self.cachingQueue.insert(url, at: 0)
            case .low:
                self.cachingQueue.append(url)
            }
        }
    }
    
    /// Starts the caching process for the first URL in the queue.
    private func startCachingAsset(_ url: URL) async {
        isCaching = true
        do {
            let (location, _) = try await URLSession.shared.download(from: url)
            let localURL = fileURL(for: url)
            try fileManager.moveItem(at: location, to: localURL)
            
            queue.async(flags: .barrier) {
                self.isCaching = false
                self.cachingQueue.removeAll { $0 == url }
            }
        } catch {
            queue.async(flags: .barrier) {
                self.isCaching = false
            }
        }
    }
    
    /// Returns the local file URL for a cached video.
    /// - Parameter url: The URL of the video.
    /// - Returns: A URL pointing to the local file location.
    private func fileURL(for url: URL) -> URL {
        return videoCacheDirectory.appendingPathComponent(url.lastPathComponent)
    }
    
    // MARK: - Enums
    
    enum CachingPriority {
        case high
        case low
    }
}
