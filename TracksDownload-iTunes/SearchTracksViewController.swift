//
//  SearchTracksViewController.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/15.
//  Copyright © 2016年 guo. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchTracksViewController: UIViewController, NSURLSessionDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [TrackModel]()
    var trackDownload = [String: DownloadModel]()
    
    
    var task_queryTracks: NSURLSessionTask?
    let session_queryTracks = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(self.dismissKeyboard))
        return recognizer
    }()
    lazy var session_downloadTracks: NSURLSession = {
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    // MARK: Sys
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tintColor = UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1)
        self.view.backgroundColor = tintColor
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    // MARK: Action
    
    // 处理搜索到的歌曲信息
    func updateSearchResults(data: NSData?) {
        
        searchResults.removeAll()
        
        do {
            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
                
                // 解析数据
                if let array: AnyObject = response["results"] {
                    for trackDictonary in array as! [AnyObject] {
                        if let trackDictonary = trackDictonary as? [String: AnyObject], previewUrl = trackDictonary["previewUrl"] as? String {
                            // Parse the search result
                            let name = trackDictonary["trackName"] as? String
                            let artist = trackDictonary["artistName"] as? String
                            searchResults.append(TrackModel(name: name, artist: artist, url: previewUrl))
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPointZero, animated: false)
        }
    }
    
    func startDownload(track: TrackModel) {
        
        if let urlString = track.trackPreviewUrl, url = NSURL(string:urlString) {
            
            var download = DownloadModel(downloadUrl: urlString)
            
            download.downloadTask = session_downloadTracks.downloadTaskWithURL(url)
            download.downloadTask?.resume()
            download.isDownloading = true
    
            trackDownload[urlString] = download
        }
    }
    
    func pauseDownload(track: TrackModel) {
        // TODO
    }
    
    func cancelDownload(track: TrackModel) {
        // TODO
    }
    
    func resumeDownload(track: TrackModel) {
        // TODO
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    // 返回正在下载的歌曲所在的 cell 的索引
    func cellIndexOfDownloadTrack(downloadTrack:NSURLSessionDownloadTask) -> Int? {
        
        if let url = downloadTrack.originalRequest?.URL?.absoluteString {
            
            for (index, track) in searchResults.enumerate() {
                
                if url == track.trackPreviewUrl {
                    return index
                }
            }
        }
        return nil
    }
    
    // 判断本地是否存在指定歌曲
    func localFileExistsForTrack(track: TrackModel) -> Bool {
        
        if let urlString = track.trackPreviewUrl, localUrl = localFilePathForUrl(urlString) {
            
            var isDir : ObjCBool = false
            if let path = localUrl.path {
                
                return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
            }
        }
        return false
    }
    
    // 生成本地存储路径 URL
    func localFilePathForUrl(previewUrl: String) -> NSURL? {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        if let url = NSURL(string: previewUrl), lastPathComponent = url.lastPathComponent {
            
            let fullPath = documentsPath.stringByAppendingPathComponent(lastPathComponent)
            return NSURL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    // 播放歌曲
    func playDownloadTrack(track: TrackModel) {
        
        if let urlString = track.trackPreviewUrl, url = localFilePathForUrl(urlString) {
            
            let moviePlayer: MPMoviePlayerViewController! = MPMoviePlayerViewController(contentURL: url)
            presentMoviePlayerViewControllerAnimated(moviePlayer)
        }
    }

}

// MARK: UISearchBarDelegate

extension SearchTracksViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        dismissKeyboard()
        
        let searchString = searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if !searchString.isEmpty {
            
            // 1
            if task_queryTracks != nil {
                task_queryTracks?.cancel()
            }
            // 2
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            // 3 设置允许包含在搜索关键词中的字符
            let expectedCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
            let searchTerm = searchString.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)
            
            // 4
            let urlString = "http://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm!)"
            let url = NSURL(string: urlString)
            
            // 5 生成查询任务对象
            task_queryTracks = session_queryTracks.dataTaskWithURL(url!, completionHandler: { [unowned self](data, response, error) in
                
                // 6
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                
                // 7
                if let error = error {
                    print(error.localizedDescription)
                }
                else if let httpResponse = response as? NSHTTPURLResponse {
                    
                    if httpResponse.statusCode == 200 {
                        self.updateSearchResults(data)
                    }
                }
            })
            
            // 8 开始查询
            task_queryTracks?.resume()
        }
    }
}

// MARK: TrackCellDelegate

extension SearchTracksViewController: TrackCellDelegate {
    
    func pauseBtnClick(cell: TrackCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            
            let track = searchResults[indexPath.row]
            
            //暂停这首歌曲的下载
            pauseDownload(track)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func resumeBtnClick(cell: TrackCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            
            let track = searchResults[indexPath.row]
            
            //恢复这首歌曲的下载
            resumeDownload(track)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func cancelBtnClick(cell: TrackCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            
            let track = searchResults[indexPath.row]
            
            //取消这首歌曲的下载
            cancelDownload(track)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func downloadBtnClick(cell: TrackCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            
            let track = searchResults[indexPath.row]
            
            //下载这首歌曲
            startDownload(track)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
}

extension SearchTracksViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TRACK_CELL", forIndexPath: indexPath) as!TrackCell
        cell.delegate = self
        
        let track = searchResults[indexPath.row]
        
        // 填充属性
        cell.lb_trackName.text = track.trackName
        cell.lb_trackArtist.text = track.trackArtist
        
        // 根据歌曲是否已经下载，更新下载按钮的状态
        let trackHaveDownloaded = localFileExistsForTrack(track)
        cell.selectionStyle = trackHaveDownloaded ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
        cell.btn_download.hidden = trackHaveDownloaded
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension SearchTracksViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = searchResults[indexPath.row]
        if localFileExistsForTrack(track) {
            playDownloadTrack(track)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: NSURLSessionDownloadDelegate

extension SearchTracksViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        // 1
        let originalURL: String? = downloadTask.originalRequest?.URL?.absoluteString
        if let url = originalURL, destinationURL = localFilePathForUrl(url) {
            
            print(destinationURL)
            
            // 2
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(destinationURL)
            } catch {
                //
            }
            
            do {
                try fileManager.copyItemAtURL(location, toURL: destinationURL)
            } catch let error as NSError {
                print("Could not copy file to disk:\(error.localizedDescription)")
            }
        }
        
        // 3
        if let url = originalURL {
            
            trackDownload[url] = nil
            // 4
            if let index = cellIndexOfDownloadTrack(downloadTask) {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    [unowned self] in
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index,inSection: 0)], withRowAnimation: .None)
                })
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // 1
        if let url = downloadTask.originalRequest?.URL?.absoluteString, var trackDownload = trackDownload[url] {
            
            // 2
            trackDownload.downloadProgress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            // 3
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: .Binary)
            // 4
            if let index = cellIndexOfDownloadTrack(downloadTask), trackCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? TrackCell {
                
                dispatch_async(dispatch_get_main_queue(), { 
                    trackCell.v_progress.progress = trackDownload.downloadProgress
                    trackCell.lb_progress.text = String(format: "%.1f%% of %@", trackDownload.downloadProgress*100,totalSize)
                })
            }
        }
    }
}

