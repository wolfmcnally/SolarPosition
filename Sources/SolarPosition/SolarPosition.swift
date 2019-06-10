//
//  SolarPosition.swift
//  SolarPosition
//
//  Created by Wolf McNally on 7/6/17.
//  Copyright © 2017 Arciem LLC. All rights reserved.
//

//
//  SolarPosition.swift
//  spa
//
//  Created by Daniel Müllenborn on 13/12/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import CSPA

public typealias FractionalTime = Double

//extension FractionalTime {
//  var fractionalTime: String {
//    let min = 60 * (self - Double(Int(self)))
//    let sec = 60 * (min - Double(Int(min)))
//    return "\(Int(self)):\(Int(min)):\(Int(sec))"
//  }
//}

public typealias Degree = Double

//extension Degree {
//  var stringValue: String {
//    let nf = NumberFormatter()
//    nf.numberStyle = .decimal
//    return nf.string(from: self)!
//  }
//}

func deg2rad(_ degrees: Double) -> Double {
    return (Double.pi / 180) * degrees
}

func rad2deg(_ radians: Double) -> Double {
    return radians * (180 / Double.pi)
}

//  enum InvalidInput: Error {
//    case year, month, day, hour, minute, second, pressure, temperature, delta_t, timezone, longitude, latitude, atmos_refract, elevation, slope, azm_rotation
//  }

public struct SolarPosition {
    struct InputValues {
        var year: Int
        var month: Int
        var day: Int
        var hour: Int
        var minute: Int
        var second: Int
        var timezone: Double
        var delta_t: Double
        var longitude: Double
        var latitude: Double
        var elevation: Double
        var pressure: Double
        var temperature: Double
        var slope: Double
        var azm_rotation: Double
        var atmos_refract: Double
    }

    public struct OutputValues {
        public var zenith: Degree
        public var azimuth180: Degree
        public var azimuth: Degree
        public var incidence: Degree
        public var elevation: Degree
        public var suntransit: FractionalTime
        public var sunrise: FractionalTime
        public var sunset: FractionalTime
    }

    public struct Location {
        public var longitude: Double
        public var latitude: Double
        public var elevation: Double

        public init(longitude: Double, latitude: Double, elevation: Double = 0) {
            self.longitude = longitude
            self.latitude = latitude
            self.elevation = elevation
        }
    }

    public enum OutputSelector: Int32 {
        case za, zaInc, zaRTS, all
    }

    static func estimateDelta_T(_ date: Date) -> Double {
        let calendar = Calendar.current
        let year = Double(calendar.component(.year, from: date))
        var ΔT = 62.92 + 0.32217 * (year - 2000)
        ΔT += 0.005589 * pow(year - 2000, 2.0)
        return ΔT
    }

    public static func calculate(date: Date, location: Location, outputSelector: OutputSelector = .all) -> OutputValues {
        let timeZone = Double(TimeZone.current.secondsFromGMT()) / 3600
        let ΔT = estimateDelta_T(date)
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let values = InputValues(year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!, minute: comps.minute!, second: comps.second!, timezone: timeZone, delta_t: ΔT, longitude: location.longitude, latitude: location.latitude, elevation: location.elevation, pressure: 1000, temperature: 20, slope: 0, azm_rotation: 0, atmos_refract: 0.5667)
        let result = SolarPosition.calculate(input: values, outputSelector: outputSelector)
        return result
    }

    static func trackingAngle(azimuth az: Degree, zenith el: Degree) -> Degree {

        let azimuth = deg2rad(az)
        let zenith = deg2rad(el)

        let rad = atan(tan(Double.pi/2-zenith)*sqrt(cos(azimuth)*cos(azimuth)))

        return rad2deg(rad)
    }

    private static func calculate(input: InputValues, outputSelector: OutputSelector) -> OutputValues {
        var data = spa_data()
        data.year          = Int32(input.year)
        data.month         = Int32(input.month)
        data.day           = Int32(input.day)
        data.hour          = Int32(input.hour)
        data.minute        = Int32(input.minute)
        data.second        = Int32(input.second)
        data.timezone      = input.timezone
        data.delta_t       = input.delta_t
        data.longitude     = input.longitude
        data.latitude      = input.latitude
        data.elevation     = input.elevation
        data.pressure      = input.pressure
        data.temperature   = input.temperature
        data.slope         = input.slope
        data.azm_rotation  = input.azm_rotation
        data.atmos_refract = input.atmos_refract
        data.function      = outputSelector.rawValue

        _ = spa_calculate(&data)
        /*
         switch result {
         case 0:
         break
         case 1:
         throw InvalidInput.year
         case 2:
         throw InvalidInput.month
         case 3:
         throw InvalidInput.day
         case 4:
         throw InvalidInput.hour
         case 5:
         throw InvalidInput.minute
         case 6:
         throw InvalidInput.second
         case 7:
         throw InvalidInput.delta_t
         case 8:
         throw InvalidInput.timezone
         case 9:
         throw InvalidInput.longitude
         case 10:
         throw InvalidInput.latitude
         case 11:
         throw InvalidInput.atmos_refract
         case 12:
         throw InvalidInput.elevation
         case 13:
         throw InvalidInput.year
         case 14:
         throw InvalidInput.slope
         case 15:
         throw InvalidInput.azm_rotation
         default:
         break
         }
         */

        return OutputValues(
            zenith: data.zenith,
            azimuth180: data.azimuth180,
            azimuth: data.azimuth,
            incidence: data.incidence,
            elevation: data.e,
            suntransit: data.suntransit,
            sunrise: data.sunrise,
            sunset: data.sunset)
    }
}
