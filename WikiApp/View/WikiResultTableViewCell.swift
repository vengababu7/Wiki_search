//
//  WikiResultTableViewCell.swift
//  WikiApp
//
//  Created by Maparthi Venga on 09/16/18.
//  Copyright © 2018 Maparthi Venga. All rights reserved.
//

import UIKit

class WikiResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var titleLabelOutlet: UILabel!
    @IBOutlet weak var subtitleLabelOutlet: UILabel!
    
    var pageResult : Result? {
        didSet {
            self.imageViewOutlet.image = nil
            if let result = pageResult {
                titleLabelOutlet.text = result.title
                if let description = result.terms?.description {
                    if description.count>0 {
                        subtitleLabelOutlet.text = description[0]
                    }
                }
                self.setImage(withResult: result)
            }
        }
    }
    
    private func setImage(withResult result: Result) {
        if let imageURl = result.thumbnail?.source {
            let cache = WikiCache.shared
            cache.getImage(forKey: imageURl) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.imageViewOutlet.image = image
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
