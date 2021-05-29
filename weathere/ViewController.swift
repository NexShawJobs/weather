//
//  ViewController.swift
//  weathere
//
//  Created by NebSha on 5/28/21.
//

import UIKit

//VIEW CONTROLLER
class ViewController: UITableViewController {
    var weatherVModel:WeatherViewModel = WeatherViewModel()
    var weatherResponses:[WeatherResponse] = []
    var weatherIcons:[UIImage] = []
    var cities = ["Irving", "Houston", "Boston", "Dallas"]
    let numberOfItemsInWeather = 10
    let heightForFooterSection = 29
    let heightForHeaderSection = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadDefaultWeatherData()
    }
    func setupView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "WeatherIconCell", bundle: nil), forCellReuseIdentifier: "WeatherIconCell")
        self.tableView.register(UITableViewCell.self,
         forCellReuseIdentifier: "cell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInWeather
    }
    override func numberOfSections(in: UITableView) -> Int {
        return cities.count
    }
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        return self.configureCell(cell: cell, indexPath: indexPath)
    }
    override func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(heightForFooterSection)
    }
    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(heightForHeaderSection)
    }
    override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 60))
        label.font = UIFont.systemFont(ofSize: 44)
        label.text = self.cities[section]
        label.textAlignment = .center
        view.addSubview(label)
        view.backgroundColor = .systemGreen
        return view
    }
    func configureCell(cell: UITableViewCell, indexPath:IndexPath) -> UITableViewCell {
        if self.weatherResponses.count > indexPath.section && self.weatherIcons.count > indexPath.section {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherIconCell") as! WeatherIconCell
                cell.weatherIconImageView.image = self.weatherIcons[indexPath.section]
                return cell
            case 1:
                if let weather:[Weather] = self.weatherResponses[indexPath.section].weather {
                    cell.textLabel?.text = "Main: " + weather[0].main!
                }
            case 2:
                if let ktemp = (self.weatherResponses[indexPath.section].main?.temp){
                    let celsiusTemp = ktemp - 273.15
                    cell.textLabel?.text = "Temprature :" + String(format: "%.2f \u{00B0}C", celsiusTemp) //+ "C"
                }
            case 3:
                if let pressure = self.weatherResponses[indexPath.section].main?.pressure {
                    cell.textLabel?.text = "Pressure :" + String(pressure)
                }
            case 4:
                if let humidity = self.weatherResponses[indexPath.section].main?.humidity {
                    cell.textLabel?.text = "Humidity :" + String(humidity)
                }
            case 5:
                if let minTemp = self.weatherResponses[indexPath.section].main?.temp_min {
                    cell.textLabel?.text = "Min Temperature :" + String(minTemp)
                }
            case 6:
                if let maxTemp = self.weatherResponses[indexPath.section].main?.temp_max {
                    cell.textLabel?.text = "Max Temperature :" + String(maxTemp)
                }
            case 7:
                if let maxTemp = self.weatherResponses[indexPath.section].main?.temp_max {
                    cell.textLabel?.text = "Wind Speed :" + String(maxTemp)
                }
            case 8:
                if let sunrise = self.weatherResponses[indexPath.section].sys?.sunrise {
                let sunriseS = self.formatTimeStamp(stamp: sunrise)
                cell.textLabel?.text = "Sunrise :" + sunriseS
                }
            case 9:
                if let sunset = (self.weatherResponses[indexPath.section].sys?.sunset) {
                let sunsetS = self.formatTimeStamp(stamp: sunset)
                cell.textLabel?.text = "Sunset :" + sunsetS
                }
            default:
                cell.textLabel?.text = "No Data"
        }
        }
        return cell
    }
    func loadDefaultWeatherData(){
        for city in cities {
            self.getWeatherData(forLocation: city)
        }
    }
    func getWeatherData(forLocation location:String){
        weatherVModel.fetchWeatherData(for:weatherVModel.stringUrlForWeatherData(forLocation: location), completion: {
        do {
            let response = try JSONDecoder().decode(WeatherResponse.self, from: self.weatherVModel.weatherData)
            self.weatherResponses.append(response)
            self.getIconImage(for: response.weather![0].icon!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let err {
            print(err)
            let alert = UIAlertController(title: "No Weather Data", message: "Weather data for the selected location is not found.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            if self.weatherResponses.count > 0 && self.weatherResponses.count < self.cities.count {
                self.cities.remove(at: self.weatherResponses.count)
                self.tableView.reloadData()
            }
        }
        })
    }
    func getIconImage(for iconID: String){
        weatherVModel.fetchWeatherData(for: weatherVModel.stringUrlForImage(forIconID: iconID), completion: {
            let img:UIImage =  UIImage(data: self.weatherVModel.weatherData)!
            DispatchQueue.main.async {
                self.weatherIcons.append(img)
                self.tableView.reloadData()
            }
        })
    }
    func formatTimeStamp(stamp:Double) -> String{
        let date = NSDate(timeIntervalSince1970: stamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
        return dayTimePeriodFormatter.string(from: date as Date)
    }
}
//END VIEWCONTROLLER

//MODEL
struct WeatherResponse : Decodable {
    let coord:Coord?
    let weather:[Weather]?
    let base:String?
    let main:Main?
    let visibility:Int?
    let wind:Wind?
    let clouds:Clouds?
    let dt:Double?
    let sys:Sys?
    let id:Double?
    let name:String?
    let cod:Int?

    init(coord:Coord? = nil, weather:[Weather]? = nil, base:String? = nil,
         main:Main? = nil, visibility:Int? = nil, wind:Wind? = nil,
         clouds:Clouds? = nil, dt:Double? = nil, sys:Sys? = nil,
         id:Double? = nil, name:String? = nil, cod:Int? = nil){
        self.coord = coord
        self.weather = weather
        self.base = base
        self.main = main
        self.visibility = visibility
        self.wind = wind
        self.clouds = clouds
        self.dt = dt
        self.sys = sys
        self.id = id
        self.name = name
        self.cod = cod
    }
}
struct Coord : Decodable {
    let lon:Double?
    let lat:Double?
}
struct Weather : Decodable {
    let id:Int?
    let main:String?
    let description:String?
    let icon:String?
}
struct Main : Decodable {
    let temp:Double?
    let pressure:Float?
    let humidity:Int?
    let temp_min:Double?
    let temp_max:Double?
    let sea_level:Float?
    let grnd_level:Float?
}
struct Wind : Decodable {
    let speed:Float?
    let deg:Float?
}
struct Clouds : Decodable {
    let all:Int?
}
struct Sys : Decodable {
    let message:Double?
    let country:String?
    let sunrise:Double?
    let sunset:Double?
}
struct Icon {
    let icon:UIImage
    let urlString:String
}
//END MODEL

//VIEW MODEL
class WeatherViewModel {
    var services = Services()
    var weatherData:Data = Data()

    //get Data
    func fetchWeatherData(for urlString:String, completion:@escaping () -> ()){
        services.fetchWeatherData(for: urlString, completion: {data in
            self.weatherData = data
            completion()
        })
    }
    //URL for weather iCon
    func stringUrlForImage(forIconID iconID:String) -> String{
        return services.stringUrlForImage(forIconID:iconID)
    }
    //URL for weather data
    func stringUrlForWeatherData(forLocation location:String) -> String{
        return  services.stringUrlForWeatherData(forLocation: location)
    }
}
//END VIEW MODEL

class Services: NSObject {
    static let baseURL = "http://api.openweathermap.org/data/2.5/weather?appid=b274c5ce65b3e435688f3098769c6dee&q="
    static let baseIconURL = "http://openweathermap.org/img/w/"

    func fetchWeatherData(for strUrl:String, completion:@escaping (Data) -> ())  {
        guard let url = URL(string: strUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {
                return
            }
                completion(data)
                return
            }.resume()
    }
    func stringUrlForImage(forIconID iconID:String) -> String{
        return Services.baseIconURL + iconID + ".png"
    }
    func stringUrlForWeatherData(forLocation location:String) -> String{
        return Services.baseURL + location
    }
}
