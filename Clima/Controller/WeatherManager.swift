//
//  WeatherManager.swift
//  Clima
//
//  Created by Khue on 27/07/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let userAPIKey = "e800afc8fee0487e98a21761ad8b0e66"
    let url = "https://api.openweathermap.org/data/2.5/weather?units=metric"
    //unit de chuyen nhiet do sang do C
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherAPI(cityName: String) {
        let weatherURL = "\(url)&q=\(cityName)&appid=\(userAPIKey)"
        print(weatherURL)
        performRequest(with: weatherURL)
    }
    
    func fetchWeatherAPI(latitude lat: Double, longitude lon: Double){
        let weatherURL = "\(url)&appid=\(userAPIKey)&lat=\(lat)&lon=\(lon)"
        print(weatherURL)
        performRequest(with: weatherURL)
    }
    
    func performRequest(with urlString: String){
        //1: Tao url
        if let url = URL(string: urlString) {
            // Tao url session
            let session = URLSession(configuration: .default)
            //Tao task cho urlSession
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error!)
                    return
                }
                
                if let safedata = data {
//                    Cach chuyen data sang String
//                    let dataString = String(data: safedata, encoding: .utf8)!
                    if let weather = parseJSON(safedata) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                return
            }
            
            //Thuc hien task
            task.resume()
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let temperature = decodedData.main.temp
            let conditionID = decodedData.weather[0].id
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: conditionID, name: name, temperature: temperature)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
        
    }
    
}
