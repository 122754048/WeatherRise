import Foundation
import CoreLocation

class WeatherService {
    private let apiKey = "YOUR_API_KEY"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"

    func fetchWeatherInfo(for location: CLLocation, completion: @escaping (WeatherInfo?) -> Void) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch weather data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
                completion(weatherInfo)
            } catch {
                print("Failed to parse weather data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
