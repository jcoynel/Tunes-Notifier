//
//  Track.swift
//  Tunes Notifier
//
//  Created by Jules Coynel on 16/05/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

import Foundation

public class Track {
    let name: String?
    let artist: String?
    let album: String?
    
    init(name: String?, artist: String?, album: String?) {
        self.name = name
        self.artist = artist
        self.album = album
    }
}
