//
//  DefaultsKeys.swift
//  WeatherApp
//
//  Created by Diem on 26/6/2021.
//

import Foundation

import SwiftyUserDefaults

//enum mostRcentSearchBy: String  {
//    case zipCode
//    case coordinate
//}
//let Defaults = SwiftyUserDefaults.Defaults

extension DefaultsKeys {
    
    var mostRcentSearchCoordinateLatArr: DefaultsKey<[Double]> { .init("mostRcentSearchCoordinateLatArr",defaultValue: [])}
    var mostRcentSearchCoordinateLongArr: DefaultsKey<[Double]> { .init("mostRcentSearchCoordinateLongArr",defaultValue: [])}
    var mostRcentSearchTitleArr: DefaultsKey<[String]> { .init("mostRcentSearchTitleArr",defaultValue: [])}

    
}
