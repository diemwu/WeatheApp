//
//  HttpConnector.swift
//  WeatherApp
//
//  Created by Diem on 25/6/2021.
//

import Foundation
import Alamofire
import SwiftyJSON

enum NetworkError: Error {
    case failure
    case success
}

class HttpConnector {
    
    func getRequest(getUrl:String,parameters: [String: Any],completion:@escaping (Result<JSON, NetworkError>) -> Void ){
        
//        var jsonCallback: JSON? = [];
//        guard let url = URL(string: getUrl) else { return jsonCallback!}
        let url = URL(string: getUrl);
        AF.request(url!,parameters: parameters).validate().responseJSON {
            (response) in
               switch response.result {
               case .success(let value):
                   let json = JSON(value)
                   print("HttpConnector -> getRequest ->JSON: \(json)")
                completion(.success(json))
               case .failure(let error):
                let err = JSON(error)
                print("HttpConnector -> getRequest ->error: \(err)")

                completion(.success(err))
               }
           }
        
//        return jsonCallback!
    }
}
