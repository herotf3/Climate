//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "52f0805396443be725fd687d0d46ed05"
    

    //TODO: Declare instance variables here
    let locationManager=CLLocationManager()
    let weatherDataModel=WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //getWeatherData method here:
    func getWeatherData(url:String,params:[String:String]){
        Alamofire.request(url, method: .get, parameters: params).responseJSON{
            response in
            if response.result.isSuccess {
                print("get \(url) response success")
                
                let jsonWeather:JSON = JSON(response.result.value!)
                print(jsonWeather)
                self.updateWeatherData(json: jsonWeather)
            }else{
                print("error \(String(describing: response.result.error))")
                self.cityLabel.text="Connection Issues"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //updateWeatherData method here:
    func updateWeatherData(json:JSON){
        
        if let tempResult = json["main"]["temp"].double {
        //get data
        weatherDataModel.temperature=Int(tempResult-273.15)
        weatherDataModel.city=json["name"].string!
        weatherDataModel.condition=json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName=weatherDataModel.updateWeatherIcon(
                    condition: weatherDataModel.condition)
        //update UI
        updateUIWithWeatherData()
        }else{
            //unexpected data
            cityLabel.text="Weather Unavailable"
            print("error: unexpected response")
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData(){
        cityLabel.text=weatherDataModel.city
        temperatureLabel.text="\(weatherDataModel.temperature)°"
        weatherIcon.image=UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //didUpdateLocations:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location=locations[locations.count-1]   //pick the last location
        
        if location.horizontalAccuracy>0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            
            print("lat=\(location.coordinate.latitude), long=\(location.coordinate.longitude)")
            
            let lat=String(location.coordinate.latitude)
            let lng=String(location.coordinate.longitude)
            
            let params : [String:String] = ["lat":lat,"lon":lng,"appid":APP_ID]
            
            getWeatherData(url: WEATHER_URL, params: params)
        }
    }
    
    
    //
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text="Location unavailable"
    
    }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //userEnteredANewCityName Delegate method:
    func userChangeCity(city: String) {
        print("user change city to \(city)")
        //call api get weather with city
        let params: [String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, params: params)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="changeCityName" {
            //get dest's VC
            let destinationVC = segue.destination as! ChangeCityViewController
            //set delegate for this weather view controller
            destinationVC.delegate=self
        }
    }
    
    
    
    
}


