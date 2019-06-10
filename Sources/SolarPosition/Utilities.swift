import Foundation

let twoPi = Double.pi * 2

func degrees(for radians: Double) -> Double {
    return radians / .pi * 180
}

extension Date {
    var julianMoment: Double {
        let secondsPerDay =  86400.0  // 24 * 60 * 60
        let gregorian20010101 = 2451910.5 // Julian date of 00:00 UT on 1st Jan 2001 which is NSDate's reference date.
        return self.timeIntervalSinceReferenceDate / secondsPerDay + gregorian20010101
    }

    var julianDay: Int {
        let julianDayNumber = Int(round(julianMoment))
        return julianDayNumber
    }
}
