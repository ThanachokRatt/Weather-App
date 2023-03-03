//
//  WheatherManager.swift
//  Weather App
//
//  Created by Schweppe on 2/3/2566 BE.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3a0f57234a1bbe9be80d65d716089d2e&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perfromRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        perfromRequest(with: urlString)
    }
    
    func perfromRequest(with urlString: String){
        //1 Creat a URL
        if let url = URL(string: urlString) {
            //2 Creat a URL session
            let session = URLSession(configuration: .default)
            
            //3 Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                    
                }
            }
            //4 Start the task
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
           
            
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}

