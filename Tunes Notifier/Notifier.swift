//
//  Notifier.swift
//  Tunes Notifier
//
//  Created by Jules Coynel on 16/05/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

import Foundation
import ScriptingBridge

public class Notifier: NSObject, NSUserNotificationCenterDelegate {
    
    private let spotifyBundleIdentifier = "com.spotify.client"
    
    private var spotify: SBApplication? {
        return SBApplication.applicationWithBundleIdentifier(spotifyBundleIdentifier) as? SBApplication
    }
    
    override init() {
        super.init()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "spotifyPlaybackStateDidChange:",
            name: "com.spotify.client.PlaybackStateChanged",
            object: nil)
    }
    
    deinit {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Player State
    
    func spotifyPlaybackStateDidChange(notification: NSNotification) {
        if self.spotify?.running == true {
            if let userInfo = notification.userInfo {
                if userInfo["Player State"] as? String == "Playing" {
                    let track = Track(
                        name: userInfo["Name"] as? String,
                        artist: userInfo["Artist"] as? String,
                        album: userInfo["Album"] as? String)
                    
                    self.sendNotificationForTrack(track)
                }
            }
        }
    }
    
    // MARK: Notifications
    
    func sendNotificationForTrack(track: Track) {
        let notification = NSUserNotification(track: track)
        notification.soundName = nil
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        self.cleanNotificationCenter()
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func cleanNotificationCenter() {
        NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
    }
    
    // MARK: NSUserNotificationCenterDelegate
    
    public func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        self.spotify?.activate()
    }
}

extension NSUserNotification {
    convenience init(track: Track) {
        self.init()
        
        self.title = track.name
        self.subtitle = track.artist
        self.informativeText = track.album
    }
}