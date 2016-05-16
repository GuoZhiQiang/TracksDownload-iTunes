//
//  TrackModel.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/16.
//  Copyright © 2016年 guo. All rights reserved.
//

import Foundation

struct TrackModel {
    
    var trackName: String?
    var trackArtist: String?
    var trackPreviewUrl: String?
    
    init(name: String?, artist: String?, url: String) {
        
        self.trackName = name
        self.trackArtist = artist
        self.trackPreviewUrl = url
    }
    
}
