//
//  NoteCell.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/16/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

import UIKit
import Photos

class NoteCell: UITableViewCell {
    @IBOutlet weak var noteimage: UIImageView!
    @IBOutlet weak var notetitle: UILabel!
    @IBOutlet weak var noteauthor: UILabel!
    @IBOutlet weak var notedate: UILabel!
    
    func setNote(note: Note){
        if((note.noteImageURL=="")){
            self.noteimage.image = UIImage(named: "defaultimage")
        }else {
            print(note.noteImageURL)
            let url = NSURL(string: note.noteImageURL!)
            loadImage(url: note.noteImageURL!)
        }        
        notetitle.text = note.noteTitle
        notedate.text = note.noteCreatedDate?.toString(dateFormat: "MM/dd/yy")
        noteauthor.text = note.noteAuthor
    }
    
    func loadImage(url:String){
        let assetUrl = URL(string: url )!
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil)
        if let photo = fetchResult.firstObject {
            PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) {
                image, info in
                let myImage = image
                self.noteimage.image = myImage
            }
        }
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
