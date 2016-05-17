//
//  DownloadModel.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/17.
//  Copyright © 2016年 guo. All rights reserved.
//

import Foundation

struct DownloadModel {
    
    var downloadUrl: String
    var isDownloading = false
    var downloadProgress:Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    var downloadResumeData: NSData?
    
    init(downloadUrl: String) {
        self.downloadUrl = downloadUrl
    }
}
