@testable import WeatherRise
import XCTest
import CoreLocation

class WeatherRiseTests: XCTestCase {

    var appState: AppState!

    override func setUpWithError() throws {
        appState = AppState()
    }

    override func tearDownWithError() throws {
        appState = nil
    }

    func testParseWeatherInfo() {
        let weatherInfo: [String: Any] = [
            "main": [
                "temp": 20.0,
                "humidity": 50
            ],
            "weather": [
                ["description": "sunny"]
            ]
        ]

        let (temp, description) = appState.parseWeatherInfo(weatherInfo: weatherInfo)!
        XCTAssertEqual(temp, 20.0)
        XCTAssertEqual(description, "sunny")
    }

    func testFetchWeatherData() {
        let expectation = expectation(description: "Weather info fetched successfully.")

        let mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        appState.fetchWeatherData(location: mockLocation) { (weatherInfo) in
            XCTAssertNotNil(weatherInfo?.main.temp)
            XCTAssertEqualWithAccuracy(weatherInfo?.main.temp ?? -1.0, 20.0, accuracy: 1.0)
            XCTAssertEqual(weatherInfo?.weather.first?.description, "sunny")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("Error waiting for expectations: \(error.localizedDescription)")
            }
        }
    }

    func testHumidityParsing() {
        let weatherInfo: [String: Any] = [
            "main": [
                "humidity": 50
            ]
        ]

        let humidity = appState.parseHumidity(weatherInfo: weatherInfo)
        XCTAssertEqual(humidity, 50)
    }

}
