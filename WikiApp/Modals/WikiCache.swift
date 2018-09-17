//
//  WikiWebCache.swift
//  WikiApp
//
//  Created by Maparthi Venga on 09/16/18.
//  Copyright © 2018 Maparthi Venga. All rights reserved.
//

import Foundation
import UIKit

class WikiCache {
    
    /// Making cache init private so that instance will be used locally
    private init() {
        self.cache = NSCache()
    }
    
    typealias wikiImageCompletionHandler = (UIImage?) -> Void
    
    ///
    static let shared = WikiCache()
    var cache : NSCache<NSString, AnyObject>!
    
    private func writeData(withData data: Data, withKey key:String) {
        self.cache.setObject(data as AnyObject, forKey: key as NSString)
    }
    
    func getData(forKey key: String) -> Data? {
        guard let obj = self.cache.object(forKey: key as NSString) as? Data else { return nil }
        print("Fetch Data from cache")
        return obj
    }
    
    func update(_ data : Data, forKey key : String) {
        if self.cache.object(forKey: key as NSString) as? Data != nil {
            print("Already available")
        } else {
            
            self.writeData(withData: data, withKey: key)
            print("Data Update")
        }
    }
    
    func getImage(forKey key : String, withCompletionBlock : @escaping wikiImageCompletionHandler) {
        if let data = self.cache.object(forKey: key as NSString) as? Data {
            withCompletionBlock(UIImage(data: data, scale: 1.0))
        } else {
            DispatchQueue.global().async {
                guard let url = URL(string: key) else { return }
                do {
                    guard let data = try? Data(contentsOf: url) else { return }
                    withCompletionBlock(UIImage(data: data))
                    self.writeData(withData: data, withKey: key)
                }
            }
        }
    }
    
    func clearData() {
        self.cache.removeAllObjects()
        print("Cleared all cache data")
    }
}
