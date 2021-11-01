//
//  TapViewControllerConnector.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import protocol TapAdditionsKitV2.ClassProtocol
import struct TapAdditionsKitV2.TypeAlias
import protocol TapApplicationV2.TapApplication
import class UIKit.UIImage.UIImage

/// Connection manager to connect with other modules.
public class TapViewControllerConnector {

    /// Application interface.
    public static var applicationInterface: TapApplication?

    /// Image downloader.
    public static var imageDownloader: TapImageDownloader?

    /// Fallback image for alert view controller.
    public static var fallbackAlertControllerImage: UIImage?
}

public protocol TapImageDownloader: ClassProtocol {

    func downloadImage(from url: URL, completion: @escaping TypeAlias.OptionalImageClosure)
}
