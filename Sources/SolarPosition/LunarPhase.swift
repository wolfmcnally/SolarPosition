//
//  LunarPhase.swift
//  SolarPosition
//
//  Created by Wolf McNally on 7/19/17.
//  Copyright © 2017 Arciem LLC. All rights reserved.
//

import Foundation

public class LunarPhase {
    private typealias `Self` = LunarPhase

    /**
     * Moon's Synodic Period (Days)
     */
    public static let synodicPeriod = 29.530589

    public static let earthRadiusMiles = 3959.0

    public let date: Date

    public init(date: Date) {
        self.date = date
    }

    /**
     * Get current synodic phase of the moon
     *
     * @return Moon's age in days (number of days from New Moon)
     */
    public lazy var synodicAge: Double = {
        let moonsAge = (julianMoment - 2451550.1) / Self.synodicPeriod
        return _normalize(moonsAge) * Self.synodicPeriod
    }()

    /**
     * Distance from anomalistic phase
     *
     * @return Distance in Earth radii
     */
    public lazy var distanceInEarthRadii: Double = {
        let distanceInRadians = _normalize((julianMoment - 2451562.2) / 27.55454988) * twoPi
        let synodicAgeinRadians = synodicAge * twoPi

        let distance = 60.4 - 3.3 * cos(distanceInRadians) - 0.6
            * cos(2 * synodicAgeinRadians - distanceInRadians) - 0.5
            * cos(2 * synodicAgeinRadians)

        return distance
    }()

    public lazy var distanceInMiles: Double = {
        return self.distanceInEarthRadii * Self.earthRadiusMiles
    }()

    /**
     * Get moon's ecliptic latitude based on nodal (draconic) phase
     *
     * @return Moon's ecliptic latitude
     */
    public lazy var eclipticLatitude: Double = {
        var value = (julianMoment - 2451565.2) / 27.212220817
        value = _normalize(value)
        let eclipticLatitudeRadians = value * twoPi // Convert to radians
        let elat = 5.1 * sin(eclipticLatitudeRadians)

        return elat
    }()

    /**
     * Get the moon's ecliptic longitude based on sidereal motion
     *
     * @return Moon's ecliptic longitude
     */
    public lazy var eclipticLongitude: Double = {
        let julianMoment = self.julianMoment
        let v = ((julianMoment - 2451555.8) / 27.321582241)
        let rp = _normalize(v)

        let v1 = (julianMoment - 2451562.2) / 27.55454988
        let dp = _normalize(v1) * twoPi

        let ip = synodicAge * twoPi

        let elon = 360 * rp + 6.3 * sin(dp)
            + 1.3 * sin(2 * ip - dp)
            + 0.7 * sin(2 * ip)

        return elon
    }()

    /**
     * Get the Julian Date for the date specified by setDate()
     *
     * @return double
     */
    public lazy var julianMoment: Double = {
        return date.julianMoment
    }()


    /**
     * Return the approximate phase angle of the moon
     *
     * @param synodicAge Current age of moon
     * @return
     */
    public lazy var phaseAngle: Double = {
        var phaseAngle = synodicAge * (twoPi / Self.synodicPeriod)

        if phaseAngle > twoPi {
            phaseAngle -= twoPi
        }

        return phaseAngle
    }()

    /**
     * Get Illuminated ratio of moon according to synodic age
     *
     * @param synodicAge
     * @return
     */
    public lazy var illuminatedRatio: Double = {
        let ratioOfIllumination = 0.5 * (1 - cos(phaseAngle))

        return ratioOfIllumination
    }()

    /**
     * Normalize values
     *
     * @param value
     * @return
     */
    private func _normalize(_ value: Double) -> Double {
        var value = value - floor(value)

        if value < 0 {
            value += 1
        }

        return value
    }

    public static func test(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let formattedDate = dateFormatter.string(from: date)

        let phase = LunarPhase(date: date)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3

        func f(_ n: Double) -> String {
            return formatter.string(from: NSNumber(value: n))!
        }

        print("================= \(formattedDate) ===================")
        print("Julian moment: \(f(phase.julianMoment))")
        print("Moon's age from new (days): \(f(phase.synodicAge))")
        print("Phase Angle: \(f(degrees(for: phase.phaseAngle)))")
        print("Illuminated Ratio: \(f(phase.illuminatedRatio * 100))%")
        print("Distance (Earth radii): \(f(phase.distanceInEarthRadii))")
        print("Distance (miles): \(f(phase.distanceInMiles))")
    }
}
