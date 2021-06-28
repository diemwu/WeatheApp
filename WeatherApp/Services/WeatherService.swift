//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Diem on 25/6/2021.
//

import Foundation
import SwiftyJSON

    let httpConnector = HttpConnector()
    let config = Config()
    
public class WehatherService {

    func getWeatherByZipCode(_zipCode: String,completionHandler:@escaping (Result<JSON, NetworkError>) -> Void ){
            print( "WeatherService -> getWeatherByZipCode")
        let parameters: [String: Any] = [
            "zipCode" : _zipCode,
            "appid":config.WEATHER_API_KEY
        ];

        httpConnector.getRequest(getUrl: config.WEATHER_URL, parameters: parameters,completion:completionHandler);

    }

    func getWeatherByGpsCoordinates(_lat: Double,_lon: Double,completionHandler:@escaping (Result<JSON, NetworkError>) -> Void ){
            print( "WeatherService -> getWeatherByCurrentLocation")
        print( "lat: ", _lat);
        print( "lon: ", _lon);
        let parameters: [String: Any] = [
            "lat" : _lat,
            "lon" : _lon,
            "appid":config.WEATHER_API_KEY
        ];
        httpConnector.getRequest(getUrl: config.WEATHER_URL, parameters: parameters,completion:completionHandler);


    }
}
