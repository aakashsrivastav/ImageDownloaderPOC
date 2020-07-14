//
//  Utilities.swift
//  ImageDownloaderPOC
//
//  Created by Aakash Srivastav on 05/08/18.
//  Copyright © 2018 Aakash Srivastav. All rights reserved.
//

import UIKit

func print_debug <T>(_ object: T) {
    #if DEBUG
    print(object)
    #endif
}
