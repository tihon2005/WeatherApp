import UIKit
import SnapKit

class WeatherView: UIViewController {
    
    //MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var backgroundGradient: CAGradientLayer!
    
    //MARK: - Images Strings
    
    private var weatherString = "cloud.sun.fill"
    
    private var thermometerString = "thermometer.medium"
    
    private var timeString = "sun.max.fill"
    
    //MARK: - Labels Strings
    
    private var time = "00:00"
    
    private var temperature: Double = 10
    
    private var windSpeed: Double = 1
    
    private var windDirection = 0
    
    //MARK: - Lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        getWeather()
    }
    
    //MARK: - Private methods
    
    private func setTemperature() {
        if self.temperature < 0.0 {
            self.thermometerString = "thermometer.snowflake"
            self.weatherString = "snowflake"
        } else if self.temperature < 10.0 {
            self.thermometerString = "thermometer.low"
            self.weatherString = "cloud.fill"
        } else if self.temperature < 25.0 {
            self.thermometerString = "thermometer.medium"
        } else {
            self.thermometerString = "thermometer.high"
            self.weatherString = "sun.max.fill"
        }
    }
    
    private func configureBackground() {
        backgroundGradient = CAGradientLayer.gradientLayer(in: view.bounds)
        view.layer.addSublayer(backgroundGradient)
    }
    
    private func getWeather() {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data , let weather = try? JSONDecoder().decode(WeatherData.self, from: data){
                DispatchQueue.main.async {
                    
                    self.time = weather.currentWeather.time
                    self.temperature = weather.currentWeather.temperature
                    self.windSpeed = weather.currentWeather.windspeed
                    self.windDirection = weather.currentWeather.winddirection
                    
                    self.time = String(self.time.replacingOccurrences(of: "-", with: ".").replacingOccurrences(of: "T", with: " ").dropFirst(5))
                    let realTime = Int(self.time.prefix(8).suffix(2))!
                    
                    if realTime < 6 {
                        self.timeString = "moon.fill"
                    } else if realTime < 11 {
                        self.timeString = "sun.and.horizon.fill"
                    } else if realTime > 18 && realTime < 22 {
                        self.timeString = "sun.dust.fill"
                    } else if realTime >= 22 {
                        self.timeString = "moon.fill"
                    }
                    
                    self.setTemperature()
                    
                    self.setUpView()
                }
            } else{
                print("Failed")
            }
        }
        task.resume()
    }
    
    private func setUpView() {
        let cityNameLabel = UILabel()
        cityNameLabel.text = "London, UK"
        cityNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(cityNameLabel)
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(70)
            make.centerX.equalToSuperview()
        }
        
        let weatherImage = UIImage(systemName: weatherString)?.withRenderingMode(.alwaysOriginal)
        let weatherImageView = UIImageView(image: weatherImage)
        weatherImageView.contentMode = .scaleAspectFit
        view.addSubview(weatherImageView)
        weatherImageView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.top.equalTo(cityNameLabel).inset(40)
            make.centerX.equalToSuperview()
        }
        
        let temperatureLabel = UILabel()
        temperatureLabel.text = "Temperature: \(temperature)"
        temperatureLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView).inset(235)
            make.centerX.equalToSuperview()
        }
        
        let temperatureImage = UIImage(systemName: thermometerString)?.withRenderingMode(.alwaysOriginal)
        let temperatureImageView = UIImageView(image: temperatureImage)
        temperatureImageView.contentMode = .scaleAspectFit
        view.addSubview(temperatureImageView)
        temperatureImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(weatherImageView).inset(215)
            make.left.equalTo(temperatureLabel).inset(-75)
        }
        
        
        let windSpeedLabel = UILabel()
        windSpeedLabel.text = "Wind Speed: \(windSpeed)"
        windSpeedLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(windSpeedLabel)
        windSpeedLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel).inset(90)
            make.centerX.equalToSuperview()
        }
        
        let windSpeedImage = UIImage(systemName: "wind")?.withRenderingMode(.alwaysOriginal)
        let windSpeedImageView = UIImageView(image: windSpeedImage)
        windSpeedImageView.contentMode = .scaleAspectFit
        view.addSubview(windSpeedImageView)
        windSpeedImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(temperatureImageView).inset(90)
            make.left.equalTo(temperatureLabel).inset(-75)
        }
        
        let windDirectionImage = UIImage(systemName: "tornado")?.withRenderingMode(.alwaysOriginal)
        let windDirectionImageView = UIImageView(image: windDirectionImage)
        windDirectionImageView.contentMode = .scaleAspectFit
        view.addSubview(windDirectionImageView)
        windDirectionImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(windSpeedImageView).inset(90)
            make.left.equalTo(windSpeedLabel).inset(-75)
        }
        
        let windDirectionLabel = UILabel()
        windDirectionLabel.text = "Wind Direction: \(windDirection)°"
        windDirectionLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(windDirectionLabel)
        windDirectionLabel.snp.makeConstraints { make in
            make.top.equalTo(windSpeedLabel).inset(90)
            make.right.equalTo(windDirectionImageView).inset(-278)
        }
        
        let timeImage = UIImage(systemName: timeString)?.withRenderingMode(.alwaysOriginal)
        let timeImageView = UIImageView(image: timeImage)
        timeImageView.contentMode = .scaleAspectFit
        view.addSubview(timeImageView)
        timeImageView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.top.equalTo(windDirectionImageView).inset(90)
            make.left.equalTo(windDirectionLabel).inset(-75)
        }
        
        let timeLabel = UILabel()
        timeLabel.text = "Time: \(time)"
        timeLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(windDirectionLabel).inset(90)
            make.right.equalTo(timeImageView).inset(-245)
        }
    }
}
