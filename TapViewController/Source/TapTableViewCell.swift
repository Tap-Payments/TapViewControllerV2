//
//  TapTableViewCell.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/22/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import UIKit
/// Base class for all UITableViewCells.
open class TapTableViewCell: UITableViewCell {

    // MARK: - Public -
    // MARK: Properties

    open override var isSelected: Bool {

        didSet {

            self.setSelected(self.isSelected, animated: true)
        }
    }

    // MARK: Methods

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.updateContentAttribute()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
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
