//
//  Network.swift
//  iFunnyTV
//
//  Created by Andrey Mukhametov on 18/04/16.
//  Copyright © 2016 Fun.co. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
/*
{
    "content":
    {
        "items":
        [
            {
                "url":"http://2016.secon.ru/system/partners/avatars/000/000/024/original/FunCorp.png",
                "size":
                {
                    "h":200,
                    "w":200
                },
                "id":"FunCorp",
                "type": "pic"||"gif"||"etc"
            },
            ...
        ],
        "paging":
        {
            "cursors":
            {
                "prev":"Secon2015",
                "next":"Secon2017"
            }
        }
    }
}
*/

let minContentSize: CGFloat = 100

class ContentList {
    var items: [Content]?
    var paging: Paging?
}
class Content {
    var url: String?
    var size: CGSize!
    var id: String?
    var type: String?
}
class Paging {
    var cursors: Cursors?
}
class Cursors {
    var next: String?
    var prev: String?
}
extension CGSize {
    
}

enum Router: URLRequestConvertible {
    static let baseURLString = "http://fun.co/rp"
    
    case GetFeatured(next: String?)
    
    var URLRequest: NSMutableURLRequest {
        let parameters: ([String: AnyObject]) = {
            switch self {
            case .GetFeatured(let next) where next != nil:
                return (["next": next!])
            case .GetFeatured(_):
                return ([:])
            }
        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        let URLRequest = NSURLRequest(URL: URL)
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: parameters).0
    }
}