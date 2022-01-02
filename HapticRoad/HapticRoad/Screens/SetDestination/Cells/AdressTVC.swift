//
//  AdressTVC.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/12/30.
//

import UIKit

class AdressTVC: UITableViewCell {

    @IBOutlet var destinationTitleLabel: UILabel! {
        didSet {
            destinationTitleLabel.sizeToFit()
        }
    }
    @IBOutlet var addressLabel: UILabel! {
        didSet {
            addressLabel.sizeToFit()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAppData(appData: PoiList) {
        destinationTitleLabel.text = appData.name
        addressLabel.text = appData.fullAddressRoad
    }
    
    func setupLayout() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
}
