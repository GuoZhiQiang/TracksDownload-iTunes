//
//  DownloadModel.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/18.
//  Copyright © 2016年 guo. All rights reserved.
//

import UIKit

class DownloadModel: NSObject {
    
    var downloadUrl: String
    var isDownloading = false
    var downloadProgress:Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    var downloadResumeData: NSData?
    
    init(downloadUrl: String) {
        self.downloadUrl = downloadUrl
    }

}
