//
//  ViewController.swift
//  WeatherApp
//
//  Created by Diem on 25/6/2021.
//

import UIKit
import CoreLocation
import MapKit
import SwiftyJSON
import SnapKit
import SwiftyUserDefaults



class WeatherViewController: UIViewController,UISearchBarDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var CityDescLabel: UILabel!
    @IBOutlet weak var CountryLabel: UILabel!
    @IBOutlet weak var CountryDescLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var DateDescLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var TempDescLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var StatusDescLabel: UILabel!
    @IBOutlet weak var recentSearchTableView: UITableView!
    
    var selectedAnnotation: MKPointAnnotation?
    var weatherService = WehatherService()
    var searchController = UISearchController(searchResultsController: nil)
    var locationManager = CLLocationManager()
    
    var recentSeatchLat = [Double]();
    var recentSeatchLong = [Double]();
    var recentSeatchTitle = [String]();
    
    let HK_LAT :Double =  22.302711
    let HK_LON :Double =  114.177216
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("WeatherViewController -> viewDidLoad")
        // Config Init
        title = "Search"
        recentSearchTableView.delegate = self
        recentSearchTableView.dataSource = self
        navigationItem.searchController = searchController
        searchController.automaticallyShowsCancelButton = true;
        searchController.searchBar.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        
        // App Script init
        initApp()
        addLayoutConstraint()
        
    }
    func initApp() {
        
        
        // 1. Get most Rcent Search
        let mostRecentSearchLatArr =   Defaults[\.mostRcentSearchCoordinateLatArr];
        let mostRecentSearchLonArr =   Defaults[\.mostRcentSearchCoordinateLongArr];
        let mostRecentSearchTitleArr =   Defaults[\.mostRcentSearchTitleArr];
        if !mostRecentSearchLatArr.isEmpty {
            self.recentSeatchLat = mostRecentSearchLatArr;
            self.recentSeatchLong = mostRecentSearchLonArr;
            self.recentSeatchTitle = mostRecentSearchTitleArr;
            
            let lastSearchLat = mostRecentSearchLatArr.last
            let lastSearchLong = mostRecentSearchLonArr.last
            searchWeather(latitude: lastSearchLat! , longitude:lastSearchLong!)
            
        }else{
            // 2. Search by GPS
            if CLLocationManager.locationServicesEnabled(){
                let lon = locationManager.location?.coordinate.longitude ?? HK_LON
                let lat = locationManager.location?.coordinate.latitude ?? HK_LAT
                searchWeather(latitude: lat, longitude:lon)
            }
        }
        
    }
    func addLayoutConstraint(){
        self.StatusLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.recentSearchTableView.snp.top).offset(-20)
            make.left.equalTo(self.view).offset(20)
        }
        self.StatusDescLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.recentSearchTableView.snp.top).offset(-20)
            make.left.equalTo(self.StatusLabel.snp.right).offset(10)
        }
        self.TempLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.StatusLabel.snp.top).offset(-20)
            make.left.equalTo(self.view).offset(20)
        }
        self.TempDescLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.StatusDescLabel.snp.top).offset(-20)
            make.left.equalTo(self.TempLabel.snp.right).offset(10)
        }
        
        self.DateLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.TempLabel.snp.top).offset(-20)
            make.left.equalTo(self.view).offset(20)
        }
        self.DateDescLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.TempDescLabel.snp.top).offset(-20)
            make.left.equalTo(self.DateLabel.snp.right).offset(10)
        }
        
        self.CountryLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.DateLabel.snp.top).offset(-20)
            make.left.equalTo(self.view).offset(20)
        }
        self.CountryDescLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.DateDescLabel.snp.top).offset(-20)
            make.left.equalTo(self.CountryLabel.snp.right).offset(10)
        }
        self.CityLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.CountryLabel.snp.top).offset(-20)
            make.left.equalTo(self.view).offset(20)
        }
        self.CityDescLabel.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.CountryDescLabel.snp.top).offset(-20)
            make.left.equalTo(self.CityLabel.snp.right).offset(10)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        
    }
    
    //  1.  Search by city name or zip code
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.resignFirstResponder()
        
        
        let geocder = CLGeocoder()
        geocder.geocodeAddressString(searchController.searchBar.text!, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            if error == nil{
                let anno = MKPointAnnotation()
                let placemark = placemarks?.first
                anno.coordinate = (placemark?.location?.coordinate)!
                
                print("lat",anno.coordinate.latitude)
                print("long",anno.coordinate.longitude)
                self.searchWeather(latitude: anno.coordinate.latitude, longitude: anno.coordinate.longitude,isShowSearchResultAlert: true)
                self.searchController.isActive = false
                
            }else{
                print(error?.localizedDescription ?? "error")
                self.showNoSearchResult();
                self.searchController.isActive = false
            }
        })
    }
    func showNoSearchResult(){
        let alert = UIAlertController(title: "Search", message: "No result ",preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showSearchedResultAlert(data:JSON,latitude:Double,longitude:Double){
        let alert = UIAlertController(title: "Recent Search", message: "Would you like add your recent search?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.text = (data["name"].stringValue)
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler :{ (action: UIAlertAction!) in
            
            
            if ((alert.textFields?.count)! > 0) {
                
                self.addRecentSearch(lat: latitude, long: longitude, title: (alert.textFields?[0].text)!)
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchWeather(latitude: Double , longitude:Double, isShowSearchResultAlert: Bool = false){
        weatherService.getWeatherByGpsCoordinates(_lat: latitude, _lon: longitude){(result) in
            switch result{
            case .success(let data):
                let date = Date(timeIntervalSince1970: data["dt"].doubleValue)
                let dateFormatter = DateFormatter();    dateFormatter.dateFormat = "MMM dd, yyyy";
                self.DateDescLabel.text =  (dateFormatter.string(from: date))
                let temp = data["main"]["temp"].doubleValue
                self.TempDescLabel.text =  String(format: "%0.f", temp - 273.15)
                self.CountryDescLabel.text = data["sys"]["country"].stringValue
                self.StatusDescLabel.text  = data["weather"][0]["main"].stringValue
                self.CityDescLabel.text = data["name"].stringValue
                if isShowSearchResultAlert == true {
                    self.showSearchedResultAlert(data: data, latitude: latitude, longitude: longitude)
                }
            case .failure(let networkError):
                print(networkError)
            }
            
        }
        
    }
    
    //Table View Config
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return.none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.recentSearchTableView.beginUpdates()
            recentSeatchLat.remove(at: indexPath.row-1)
            recentSeatchLong.remove(at: indexPath.row-1)
            recentSeatchTitle.remove(at: indexPath.row-1)
            Defaults[\.mostRcentSearchCoordinateLatArr].remove(at: indexPath.row-1)
            Defaults[\.mostRcentSearchCoordinateLongArr].remove(at: indexPath.row-1)
            Defaults[\.mostRcentSearchTitleArr].remove(at: indexPath.row-1)
            
            recentSearchTableView.deleteRows(at: [indexPath], with: .fade)
            self.recentSearchTableView.endUpdates()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentSeatchLat.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User touched on \(indexPath) row")
        let mostRecentSearchLatArr =   Defaults[\.mostRcentSearchCoordinateLatArr];
        let mostRecentSearchLonArr =   Defaults[\.mostRcentSearchCoordinateLongArr];
        
        if indexPath.row == 0 {
            var currentLat = 0.0
            var currentLong = 0.0
            if CLLocationManager.locationServicesEnabled() {
                currentLong = locationManager.location?.coordinate.longitude ?? HK_LON
                currentLat = locationManager.location?.coordinate.latitude ?? HK_LAT
            }
            
            searchWeather(latitude: currentLat, longitude: currentLong)
        }else{
            searchWeather(latitude: mostRecentSearchLatArr[indexPath.row-1], longitude: mostRecentSearchLonArr[indexPath.row-1])
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = Bundle.main.loadNibNamed("SearchRecentTableViewCell", owner: self, options: nil)?.first as! SearchRecentTableViewCell
        
        if indexPath.row == 0 {
            cell.recentSeratchlabel?.text = "Current Location"
        }else{
            cell.recentSeratchlabel?.text = recentSeatchTitle[indexPath.row-1]
            
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func addRecentSearch(lat: Double, long: Double,title: String) -> Void{
        
        recentSeatchLat.append(lat)
        recentSeatchLong.append(long)
        recentSeatchTitle.append(title)
        Defaults[\.mostRcentSearchCoordinateLatArr].append(lat)
        Defaults[\.mostRcentSearchCoordinateLongArr].append(long)
        Defaults[\.mostRcentSearchTitleArr].append(title)
        self.recentSearchTableView.reloadData()
    }
    
    
}

