//
//  TapCollectionViewCell.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/22/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import CoreGraphics
import UIKit
import TapAdditionsKitV2

/// Base class for all UICollectionViewCells.
open class TapCollectionViewCell: UICollectionViewCell {

    // MARK: - Public -
    // MARK: Methods

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        self.updateContentAttribute()
    }

    public override init(frame: CGRect) {

        super.init(frame: frame)
        self.updateContentAttribute()
    }

    open override func awakeFromNib() {

        super.awakeFromNib()

        self.translatesAutoresizingMaskIntoConstraints = true
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    open override func prepareForReuse() {

        super.prepareForReuse()
        self.updateContentAttribute()
    }

    // MARK: - Private -
    // MARK: Methods

    private func updateContentAttribute() {

        if let application = TapViewControllerConnector.applicationInterface {

            if #available(iOS 9.0, *) {

                self.tap_applySemanticContentAttribute(application.requiredSemanticContentAttribute)
            }
        }
    }
}
