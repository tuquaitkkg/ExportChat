//
//  ExtensionUtils.swift
//  ExportChats
//
//  Created by DatDuong on 1/25/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    var pathExtension: String {
        return fileURL.pathExtension
    }
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
}

extension String {
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
}

class ExtensionUtils: NSObject {

}
