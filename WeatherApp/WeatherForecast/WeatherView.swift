import UIKit
import Dropper
import SnapKit

class WeatherView: UIViewController, DropperDelegate {
    
    //MARK: - Properties
    
    private var backgroundGradient: CAGradientLayer!
    
    let dropper = Dropper(width: 100, height: 200)
    
    let defaults = UserDefaults.standard
    
    let cityNameButton = UIButton(type: .roundedRect)
    
    var urlString = "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
    
    var titleForButton = "London, UK"
    
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
        checkCity()
        getWeather(urlString: urlString)
    }
    
    // MARK: - Dropper
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        if contents == "London, UK" {
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
            configureBackground()
            titleForButton = "London, UK"
            defaults.set(urlString, forKey: "city")
            getWeather(urlString: urlString)
        } else if contents == "Berlin, DE" {
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=52.5200&longitude=13.4049&current_weather=true&timezone=Europe%2FBerlin"
            configureBackground()
            titleForButton = "Berlin, DE"
            defaults.set(urlString, forKey: "city")
            getWeather(urlString: urlString)
        } else if contents == "Moscow, RU" {
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=55.7512&longitude=37.6184&current_weather=true&timezone=Europe%2FMoscow"
            configureBackground()
            titleForButton = "Moscow, RU"
            defaults.set(urlString, forKey: "city")
            getWeather(urlString: urlString)
        }

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
    
    private func checkCity(){
        let cityLink = defaults.string(forKey: "city")
        if cityLink == "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"{
            titleForButton = "London, UK"
            urlString = cityLink ?? "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
        } else if cityLink == "https://api.open-meteo.com/v1/forecast?latitude=52.5200&longitude=13.4049&current_weather=true&timezone=Europe%2FBerlin"{
            titleForButton = "Berlin, DE"
            urlString = cityLink ?? "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
        } else if cityLink == "https://api.open-meteo.com/v1/forecast?latitude=55.7512&longitude=37.6184&current_weather=true&timezone=Europe%2FMoscow"{
            titleForButton = "Moscow, RU"
            urlString = cityLink ?? "https://api.open-meteo.com/v1/forecast?latitude=51.5085&longitude=-0.1257&current_weather=true&timezone=Europe%2FLondon"
        }
    }
    
    private func configureBackground() {
        backgroundGradient = CAGradientLayer.gradientLayer(in: view.bounds)
        view.layer.addSublayer(backgroundGradient)
    }
    
    private func getWeather(urlString: String) {
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
        cityNameButton.setTitle(titleForButton, for: .normal)
        cityNameButton.setTitleColor(.white, for: .normal)
        cityNameButton.titleLabel?.font = UIFont(name: "Helvetica", size: 36)
        cityNameButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(cityNameButton)
        cityNameButton.snp.makeConstraints { make in
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
            make.top.equalTo(cityNameButton).inset(40)
            make.centerX.equalToSuperview()
        }
        
        let temperatureLabel = UILabel()
        temperatureLabel.text = "Temperature: \(temperature)"
        temperatureLabel.textColor = .white
        temperatureLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView).inset(235)
            make.left.equalToSuperview().inset(85)
        }
        
        let temperatureImage = UIImage(systemName: thermometerString)?.withRenderingMode(.alwaysOriginal)
        let temperatureImageView = UIImageView(image: temperatureImage)
        temperatureImageView.contentMode = .scaleAspectFit
        view.addSubview(temperatureImageView)
        temperatureImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(weatherImageView).inset(215)
            make.left.equalToSuperview().inset(10)
        }
        
        
        let windSpeedLabel = UILabel()
        windSpeedLabel.text = "Wind Speed: \(windSpeed)"
        windSpeedLabel.textColor = .white
        windSpeedLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(windSpeedLabel)
        windSpeedLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel).inset(90)
            make.left.equalToSuperview().inset(85)
        }
        
        let windSpeedImage = UIImage(systemName: "wind")?.withRenderingMode(.alwaysOriginal)
        let windSpeedImageView = UIImageView(image: windSpeedImage)
        windSpeedImageView.contentMode = .scaleAspectFit
        view.addSubview(windSpeedImageView)
        windSpeedImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(weatherImageView).inset(305)
            make.left.equalToSuperview().inset(10)
        }
        
        let windDirectionImage = UIImage(systemName: "tornado")?.withRenderingMode(.alwaysOriginal)
        let windDirectionImageView = UIImageView(image: windDirectionImage)
        windDirectionImageView.contentMode = .scaleAspectFit
        view.addSubview(windDirectionImageView)
        windDirectionImageView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.top.equalTo(weatherImageView).inset(395)
            make.left.equalToSuperview().inset(10)
        }
        
        let windDirectionLabel = UILabel()
        windDirectionLabel.text = "Wind Direction: \(windDirection)°"
        windDirectionLabel.textColor = .white
        windDirectionLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(windDirectionLabel)
        windDirectionLabel.snp.makeConstraints { make in
            make.top.equalTo(windSpeedLabel).inset(90)
            make.left.equalToSuperview().inset(85)
        }
        
        let timeImage = UIImage(systemName: timeString)?.withRenderingMode(.alwaysOriginal)
        let timeImageView = UIImageView(image: timeImage)
        timeImageView.contentMode = .scaleAspectFit
        view.addSubview(timeImageView)
        timeImageView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.top.equalTo(weatherImageView).inset(485)
            make.left.equalToSuperview().inset(10)
        }
        
        let timeLabel = UILabel()
        timeLabel.text = "Time: \(time)"
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(windDirectionLabel).inset(90)
            make.left.equalToSuperview().inset(85)
        }
    }
    
    //MARK: - Objc methods
    @objc private func buttonTapped(sender: UIButton){
        dropper.items = ["London, UK", "Berlin, DE", "Moscow, RU"]
        dropper.theme = Dropper.Themes.white
        dropper.delegate = self
        dropper.cornerRadius = 3
        dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: cityNameButton)
    }
}
