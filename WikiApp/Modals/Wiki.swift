//
//  Wiki.swift
//  WikiApp
//
//  Created by Maparthi Venga on 09/16/18.
//  Copyright © 2018 Maparthi Venga. All rights reserved.
//

import Foundation

struct Wiki : Codable {
    let query : Query?
    let batchcomplete : Bool
}

struct Query : Codable {
    let pages: [Result]?
}

struct Result : Codable {
    let pageid : Int32?
    let ns : Int?
    let title : String?
    let thumbnail : thumbnailDetail?
    let pageimage : String?
    let terms : Terms?
}

struct  thumbnailDetail : Codable {
    let source : String?
    let width : Int?
    let height : Int?
}

struct Terms : Codable {
    let alias : [String]?
    let description : [String]?
    let label : [String]?
}
