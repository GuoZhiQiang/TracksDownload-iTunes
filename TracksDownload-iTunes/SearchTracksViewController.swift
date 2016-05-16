//
//  SearchTracksViewController.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/15.
//  Copyright © 2016年 guo. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchTracksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var searchResults = [TrackModel]()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(self.dismissKeyboard))
        return recognizer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // TODO
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as!TrackCell
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

