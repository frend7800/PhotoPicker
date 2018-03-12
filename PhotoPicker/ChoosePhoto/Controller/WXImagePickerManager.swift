//
//  WXImagePickerManager.swift
//  PhotoPicker
//
//  Created by wxj on 2017/12/12.
//  Copyright © 2017年 wxj. All rights reserved.
//

import UIKit
import Photos

class WXImagePickerManager: NSObject {

    enum ImageSourceType {
        case Album
        case Other
    }
   
    var  maxSelectCount :      Int?
    var imageManager :         PHImageManager?
    var imageRequestOption :   PHImageRequestOptions?
    var selectedImages:        NSMutableArray?
   
    
    
    
    
    
}
