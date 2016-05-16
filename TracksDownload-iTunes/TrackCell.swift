//
//  TrackCell.swift
//  TracksDownload-iTunes
//
//  Created by guo on 16/5/15.
//  Copyright © 2016年 guo. All rights reserved.
//

import UIKit

protocol TrackCellDelegate {
    
    func pauseBtnClick(cell: TrackCell)
    func resumeBtnClick(cell: TrackCell)
    func cancelBtnClick(cell: TrackCell)
    func downloadBtnClick(cell: TrackCell)
}

class TrackCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var lb_progress: UILabel!
    @IBOutlet weak var lb_trackName: UILabel!
    @IBOutlet weak var lb_trackArtist: UILabel!
    
    @IBOutlet weak var btn_pause: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_download: UIButton!
    
    @IBOutlet weak var v_progress: UIProgressView!
    
    // MARK: Delegate
    
    var delegate: TrackCellDelegate?
    

    // MARK: Sys
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Action
    
    @IBAction func pauseOrResumeBtnClick(sender: UIButton) {
        
        if sender.titleLabel!.text == "Pause" {
            delegate?.pauseBtnClick(self)
        }
        else {
            delegate?.resumeBtnClick(self)
        }
    }
    
    @IBAction func cancelBtnClick(sender: UIButton) {
        
        delegate?.cancelBtnClick(self)
    }
    
    @IBAction func downloadBtnClick(sender: UIButton) {
        
        delegate?.downloadBtnClick(self)
    }
    

}
