import Foundation
import CoreLocation
import Combine

public class LocationWeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationWeatherManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Published Location Properties
    @Published public var latitude: Double = 10.7769
    @Published public var longitude: Double = 106.7009
    @Published public var altitude: Double = 18.5
    @Published public var horizontalAccuracy: Double = 5.0
    @Published public var headingDegrees: Double = 138.0
    @Published public var compassDirection: String = "Đông Nam (SE)"
    
    // Published Address Properties
    @Published public var fullAddress: String = "Số 1 Công Xã Paris, Bến Nghé, Quận 1, TP. Hồ Chí Minh"
    @Published public var streetName: String = "Công Xã Paris"
    @Published public var districtCity: String = "Quận 1, TP. Hồ Chí Minh"
    @Published public var country: String = "Việt Nam"
    
    // Published Weather Properties
    @Published public var temperatureCelsius: Int = 31
    @Published public var weatherCondition: String = "Nắng ráo"
    @Published public var weatherIcon: String = "sun.max.fill"
    @Published public var humidityPercent: Int = 68
    
    // Authorization State
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocationReady: Bool = false
    
    override public init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0 // Update every 5 meters
        
        #if os(iOS)
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 3.0 // 3 degrees filter
        }
        #endif
        
        requestPermissionAndStart()
    }
    
    public func requestPermissionAndStart() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        #if os(iOS)
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            #if os(iOS)
            if CLLocationManager.headingAvailable() {
                locationManager.startUpdatingHeading()
            }
            #endif
        case .denied, .restricted:
            // Fall back to default preset location (e.g. Ho Chi Minh City center)
            isLocationReady = true
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude >= 0 ? location.altitude : 15.0
            self.horizontalAccuracy = location.horizontalAccuracy
            self.isLocationReady = true
        }
        
        // Reverse Geocode to obtain human readable street/ward/city
        reverseGeocode(location: location)
        
        // Update weather simulation based on coordinates and time of day
        updateWeatherForLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            let degrees = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            self.headingDegrees = degrees
            self.compassDirection = self.cardinalDirection(from: degrees)
        }
    }
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil, let place = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                var addressParts: [String] = []
                if let subThoroughfare = place.subThoroughfare { addressParts.append(subThoroughfare) }
                if let thoroughfare = place.thoroughfare { addressParts.append(thoroughfare) }
                if let subLocality = place.subLocality { addressParts.append(subLocality) }
                if let locality = place.locality { addressParts.append(locality) }
                if let adminArea = place.administrativeArea { addressParts.append(adminArea) }
                if let country = place.country {
                    self.country = country
                    addressParts.append(country)
                }
                
                let resolved = addressParts.joined(separator: ", ")
                if !resolved.isEmpty {
                    self.fullAddress = resolved
                }
                self.streetName = [place.subThoroughfare, place.thoroughfare].compactMap { $0 }.joined(separator: " ")
                self.districtCity = [place.subLocality, place.locality ?? place.administrativeArea].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
    
    private func cardinalDirection(from degrees: Double) -> String {
        switch degrees {
        case 22.5..<67.5: return "Đông Bắc (\(Int(degrees))° NE)"
        case 67.5..<112.5: return "Đông (\(Int(degrees))° E)"
        case 112.5..<157.5: return "Đông Nam (\(Int(degrees))° SE)"
        case 157.5..<202.5: return "Nam (\(Int(degrees))° S)"
        case 202.5..<247.5: return "Tây Nam (\(Int(degrees))° SW)"
        case 247.5..<292.5: return "Tây (\(Int(degrees))° W)"
        case 292.5..<337.5: return "Tây Bắc (\(Int(degrees))° NW)"
        default: return "Bắc (\(Int(degrees))° N)"
        }
    }
    
    private func updateWeatherForLocation() {
        let hour = Calendar.current.component(.hour, from: Date())
        var temp = 28
        var cond = "Nắng ráo"
        var icon = "sun.max.fill"
        var hum = 70
        
        if hour >= 6 && hour < 11 {
            temp = 29
            cond = "Nắng sớm dịu"
            icon = "sun.and.horizon.fill"
            hum = 75
        } else if hour >= 11 && hour < 15 {
            temp = 34
            cond = "Nắng gắt"
            icon = "sun.max.fill"
            hum = 60
        } else if hour >= 15 && hour < 18 {
            temp = 31
            cond = "Mây rải rác"
            icon = "cloud.sun.fill"
            hum = 68
        } else {
            temp = 27
            cond = "Mát mẻ đêm"
            icon = "moon.stars.fill"
            hum = 82
        }
        
        DispatchQueue.main.async {
            self.temperatureCelsius = temp
            self.weatherCondition = cond
            self.weatherIcon = icon
            self.humidityPercent = hum
        }
    }
    
    // MARK: - Formatted Coordinate String
    public func formattedCoordinates(latitude: Double, longitude: Double) -> String {
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"
        
        let absLat = abs(latitude)
        let latDegrees = Int(absLat)
        let latMinutes = Int((absLat - Double(latDegrees)) * 60)
        let latSeconds = Int(((absLat - Double(latDegrees)) * 60 - Double(latMinutes)) * 60)
        
        let absLon = abs(longitude)
        let lonDegrees = Int(absLon)
        let lonMinutes = Int((absLon - Double(lonDegrees)) * 60)
        let lonSeconds = Int(((absLon - Double(lonDegrees)) * 60 - Double(lonMinutes)) * 60)
        
        return "\(latDegrees)°\(latMinutes)'\(latSeconds)\"\(latDirection)  \(lonDegrees)°\(lonMinutes)'\(lonSeconds)\"\(lonDirection)"
    }
}
