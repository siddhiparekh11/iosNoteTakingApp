//
//  Note.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/16/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

import Foundation
import UIKit
class Notee {
    var image: UIImage
    var title: String
    var date: Date
    var author : String
    
    init(image:UIImage,title:String,date:Date,author:String){
      self.image = image
      self.title = title
      self.date = date
      self.author = author
    }
    
}
