//
//  GasStation+OpeningHours.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    enum OpeningHoursType {
        case open247
        case allEqual
        case weekendDifferent
        case sundayDifferent
        case allDifferent
    }

    enum OpeningHoursValue: Equatable {
        case open247
        case wholeDay
        case closed
        case daily
        case weekday(from: String, to: String)
        case day(day: String)
        case time(value: String)

        public static func == (lhs: OpeningHoursValue, rhs: OpeningHoursValue) -> Bool {
            switch (lhs, rhs) {
            case (.open247, .open247):
                return true

            case (.wholeDay, .wholeDay):
                return true

            case (.closed, .closed):
                return true

            case (.daily, .daily):
                return true

            case (.weekday(let lFrom, let lTo), .weekday(let rFrom, let rTo)):
                return lFrom == rFrom && lTo == rTo

            case (.day(let lDay), .day(let rDay)):
                return lDay == rDay

            case (.time(let lValue), .time(let rValue)):
                return lValue == rValue

            default:
                return false
            }
        }
    }
}

extension PCPOICommonOpeningHours.Rules.PCPOIDays: Comparable {
    static public func < (lhs: PCPOICommonOpeningHours.Rules.PCPOIDays, rhs: PCPOICommonOpeningHours.Rules.PCPOIDays) -> Bool {
        let order: [PCPOICommonOpeningHours.Rules.PCPOIDays] = PCPOICommonOpeningHours.Rules.PCPOIDays.allCases
        guard let lhsIndex = order.firstIndex(where: { lhs == $0 }) else { return false }
        guard let rhsIndex = order.firstIndex(where: { rhs == $0 }) else { return false }

        return lhsIndex < rhsIndex
    }
}

extension PCPOICommonOpeningHours.Rules.PCPOIAction: Comparable {
    static public func < (lhs: PCPOICommonOpeningHours.Rules.PCPOIAction, rhs: PCPOICommonOpeningHours.Rules.PCPOIAction) -> Bool {
        let order: [PCPOICommonOpeningHours.Rules.PCPOIAction] = [.open, .close]
        guard let lhsIndex = order.firstIndex(where: { lhs == $0 }) else { return false }
        guard let rhsIndex = order.firstIndex(where: { rhs == $0 }) else { return false }

        return lhsIndex < rhsIndex
    }
}

extension PCPOICommonOpeningHours.Rules {
    var isOpen247: Bool {
        return timespans?.count == 1 && (timespans?.first?.from == timespans?.first?.to) && action == .open
    }

    func rulesForHours() -> [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)] {
        return timespans?.compactMap { ($0.ruleSet(), action ?? .close) } ?? []
    }

    func rulesForPastMidnight() -> [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)] {
        let rulesForHours = rulesForHours()

        // Get the one rule that specifies opening hours past midnight
        guard let rulePastMidnight = rulesForHours.first(where: { $0.0.rangeView.contains(where: { $0.upperBound > POIKitConstants.dayInMinutes }) }),
              let range = rulePastMidnight.0.rangeView.first(where: { $0.upperBound > POIKitConstants.dayInMinutes })
        else { return [] }

        let action = rulePastMidnight.1
        let excess = range.upperBound - POIKitConstants.dayInMinutes
        let pastMidnightIndexSet = IndexSet(0 ..< excess)
        return [(pastMidnightIndexSet, action)]
    }
}

extension PCPOICommonOpeningHours.Rules.Timespans {
    func stringToMinutes() -> (from: Int, to: Int) {
        let fromCompontents: [Int] = self.from?.split(separator: ":").compactMap { Int($0) } ?? []
        let toComponents: [Int] = self.to?.split(separator: ":").compactMap { Int($0 == "0" ? "24" : $0) } ?? []

        let from = fromCompontents.enumerated().reduce(0) { $0 + $1.element * ($1.offset == 0 ? 60 : 1) }
        var to: Int = toComponents.enumerated().reduce(0) { $0 + $1.element * ($1.offset == 0 ? 60 : 1) }

        if from > to { // Add 24h because to time is in for the next day
            to += POIKitConstants.dayInMinutes
        }
        return (from, to)
    }

    func ruleSet() -> IndexSet {
        let minutes = stringToMinutes()
        return IndexSet(minutes.from ..< minutes.to)
    }
}

extension Array where Element: PCPOICommonOpeningHours.Rules {
    private var openingHoursType: POIKit.OpeningHoursType {
        if is247 { return .open247 }
        if isDaysEqual { return .allEqual }
        if isOnlyWeekendDifferent { return .weekendDifferent }
        if isOnlySundayDifferent { return .sundayDifferent }

        return .allDifferent
    }

    private var is247: Bool {
        return isDaysEqual && isOpenEveryDay && (first?.isOpen247 ?? false)
    }

    private var isDaysEqual: Bool {
        return count == 1
    }

    private var isOpenEveryDay: Bool {
        let days: [PCPOICommonOpeningHours.Rules.PCPOIDays] = compactMap { $0.action == .open ? $0.days : nil }.flatMap { $0 }
        return Set(days).count == 7
    }

    private var isOnlyWeekendDifferent: Bool {
        let weekends: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.saturday, .sunday]
        guard !isDaysEqual && isOpenEveryDay && count == 2 else { return false }
        guard contains(where: { $0.days == weekends }) else { return false }

        return true
    }

    private var isOnlySundayDifferent: Bool {
        let sunday: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.sunday]
        guard !isDaysEqual && isOpenEveryDay && count == 2 else { return false }
        guard contains(where: { $0.days == sunday }) else { return false }

        return true
    }

    private var rulesPerDay: [PCPOICommonOpeningHours.Rules.PCPOIDays: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]] {
        var rulesPerDay: [PCPOICommonOpeningHours.Rules.PCPOIDays: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]] = [:]
        for hours in self as [PCPOICommonOpeningHours.Rules] {
            let ruleSet: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)] = hours.rulesForHours()
            hours.days?.forEach {
                if rulesPerDay[$0] == nil {
                    rulesPerDay[$0] = []
                }

                rulesPerDay[$0]?.append(contentsOf: ruleSet)
            }
        }

        return rulesPerDay
    }

    private var rulesForWeekdays: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]? {
        guard let index = firstIndex(where: { $0.days == PCPOICommonOpeningHours.Rules.PCPOIDays.weekdays }) else { return nil }
        return self[index].rulesForHours()
    }

    private var rulesForWeekend: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]? {
        guard let index = firstIndex(where: { $0.days == PCPOICommonOpeningHours.Rules.PCPOIDays.weekend }) else { return nil }
        return self[index].rulesForHours()
    }

    private var rulesForMoToSat: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]? {
        guard let index = firstIndex(where: { $0.days == [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday] }) else { return nil }
        return self[index].rulesForHours()
    }

    private var rulesForSunday: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]? {
        guard let index = firstIndex(where: { $0.days == [.sunday] }) else { return nil }
        return self[index].rulesForHours()
    }

    // Methods
    private func applyRules(_ rules: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]) -> IndexSet? {
        var resultedRule: IndexSet?

        let rules = rules.sorted(by: { $0.1 < $1.1 })
        guard rules.first?.1 != .close else { return nil }

        rules.forEach { rule in
            if resultedRule == nil && rule.1 == .open {
                resultedRule = rule.0
            } else {
                if rule.1 == .open {
                    resultedRule?.formUnion(rule.0)
                } else {
                    resultedRule?.subtract(rule.0)
                }
            }
        }

        return resultedRule
    }

    private enum TimeFrame: Equatable {
        case hour(from: Int, to: Int)
        case wholeDay
    }

    private func mapTimesRangeToOpeningHoursString(_ range: Range<IndexSet.Element>) -> TimeFrame {
        var upperBound = range.upperBound
        if upperBound > POIKitConstants.dayInMinutes {
            upperBound -= POIKitConstants.dayInMinutes
        }

        if isAlwaysOpenSpecialCase(from: range.lowerBound, to: upperBound) {
            return .wholeDay
        }

        return .hour(from: range.lowerBound, to: upperBound)
    }

    /** Check the case: opening hours -> 00:00 - 23:59 */
    private func isAlwaysOpenSpecialCase(from: Int, to: Int) -> Bool {
        return from % POIKitConstants.dayInMinutes == 0 && to % POIKitConstants.dayInMinutes == 1439  // 00:00 - 23:59
    }

    /** Change opening value to 'open247' if gas station is open from 00:00 to 23:59 (aka 'wholeDay') */
    private func checkAlwaysOpenSpecialCase(timeFrames: [TimeFrame]) -> POIKit.OpeningHoursValue {
        guard let frame = timeFrames.first else {
            return .time(value: [].joined(separator: "\n"))
        }

        if frame == .wholeDay {
            return .wholeDay

        } else {
            let openingHours: [String] = timeFrames.compactMap {
                if case let .hour(from, to) = $0 {
                    return "\(minutesToTime(from, from: true)) – \(minutesToTime(to))"
                }
                return nil
            }

            return .time(value: openingHours.joined(separator: "\n"))
        }
    }

    private func generateWeekdayTimeTable() -> [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] {
        guard let rulesForWeekdays = rulesForWeekdays, let rulesForWeekend = rulesForWeekend else { return generateTimeTable() }

        var timeTable: [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] = []

        let openingHoursForWeekday: [TimeFrame] = applyRules(rulesForWeekdays)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
        let timeWeekday = checkAlwaysOpenSpecialCase(timeFrames: openingHoursForWeekday)
        timeTable.append((.weekday(from: "monday", to: "friday"), timeWeekday))

        let openingHoursForWeekend: [TimeFrame] = applyRules(rulesForWeekend)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
        let timeWeekend = checkAlwaysOpenSpecialCase(timeFrames: openingHoursForWeekend)
        timeTable.append((.weekday(from: "saturday", to: "sunday"), timeWeekend))

        return timeTable
    }

    private func generateOnlySundayDifferentTable() -> [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] {
        guard let rulesForMoToSat = rulesForMoToSat, let rulesForSunday = rulesForSunday else { return generateTimeTable() }

        var timeTable: [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] = []

        let openingHoursForMoToSat: [TimeFrame] = applyRules(rulesForMoToSat)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
        let timeMoToSat = checkAlwaysOpenSpecialCase(timeFrames: openingHoursForMoToSat)
        timeTable.append((.weekday(from: "monday", to: "saturday"), timeMoToSat))

        let openingHoursForSunday: [TimeFrame] = applyRules(rulesForSunday)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
        let timeSunday = checkAlwaysOpenSpecialCase(timeFrames: openingHoursForSunday)
        timeTable.append((.day(day: "sunday"), timeSunday))

        return timeTable
    }

    private func generateTimeTable() -> [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] {
        var timeTable: [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] = []

        let sortedRulesPerDay = rulesPerDay.sorted(by: { $0.key < $1.key })
        for rules in sortedRulesPerDay {
            let openingHoursForDay: [TimeFrame] = applyRules(rules.value)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
            if openingHoursForDay.isEmpty {
                timeTable.append((.day(day: "\(rules.key)"), .closed))
            } else {
                let time = checkAlwaysOpenSpecialCase(timeFrames: openingHoursForDay)
                guard let last = timeTable.last else {
                    timeTable.append((.day(day: "\(rules.key)"), time))
                    continue
                }
                if last.1 == time { // check if consecutive opening hours can be grouped together
                    if case .weekday(let from, _) = last.0 {
                        timeTable[timeTable.count - 1] = (.weekday(from: from, to: "\(rules.key)"), time)
                        continue
                    } else if case .day(let from) = last.0 {
                        timeTable[timeTable.count - 1] = (.weekday(from: from, to: "\(rules.key)"), time)
                        continue
                    }
                }
                timeTable.append((.day(day: "\(rules.key)"), time))
            }
        }

        return timeTable
    }

    // Public Methods
    public func minuteTillClose(from date: Date = Date()) -> Int {
        guard openingHoursType != .open247 else { return Int.max }
        let weekdays: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday] // WeekdayOrdinal starts with sunday

        var rulesForToday: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)] = []
        for hour in self as [PCPOICommonOpeningHours.Rules] {
            let weekDay = Calendar.current.component(.weekday, from: date)
            if weekDay - 1 < weekdays.count, hour.days?.first(where: { weekdays[weekDay - 1] == $0 }) != nil {
                rulesForToday.append(contentsOf: hour.rulesForHours())
            }

            // Check if there are rules of the previous day
            // that influence the opening hours of the current day
            // (e.g rules that specify opening hours past midnight of the previous day)
            let previousDayIndex = abs((weekDay - 2) % 7)
            guard let previousDay = hour.days?.first(where: { weekdays[previousDayIndex] == $0 }),
                  let previousDayOpeningHour = first(where: { $0.days?.contains(previousDay) ?? false }) else { continue }

            rulesForToday.append(contentsOf: previousDayOpeningHour.rulesForPastMidnight())
        }

        let units: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
        let components = Calendar.current.dateComponents(units, from: date)

        let minutesPassedTillMidnight = (components.minute ?? 0) + (components.hour ?? 0) * 60
        guard let appliedRules = applyRules(rulesForToday), appliedRules.contains(minutesPassedTillMidnight) else { return -Int.max }
        guard let currentRange = appliedRules.rangeView.first(where: { $0.contains(minutesPassedTillMidnight) }) else { return -Int.max }

        return currentRange.upperBound - minutesPassedTillMidnight
    }

    public func isClosed(on date: Date = Date()) -> Bool {
        minuteTillClose(from: date) == -Int.max
    }

    public func openingHours() -> [(POIKit.OpeningHoursValue, POIKit.OpeningHoursValue)] {
        switch openingHoursType {
        case .open247:
            return [(.daily, .open247)]

        case .allEqual:
            guard isOpenEveryDay else { return [(.daily, .closed)] }

            return first?.timespans?.compactMap {
                let minutes = $0.stringToMinutes()
                var to = minutes.to
                if to > POIKitConstants.dayInMinutes {
                    to -= POIKitConstants.dayInMinutes
                }

                if isAlwaysOpenSpecialCase(from: minutes.from, to: to) { // 00:00 - 23:59 - equals open247
                    return (.daily, .wholeDay)
                }

                let businessHours = "\(minutesToTime(minutes.from, from: true)) – \(minutesToTime(to))"
                let businessHoursFormatted: POIKit.OpeningHoursValue = $0.from == "0" && $0.to == "0" ? .open247 : .time(value: businessHours)
                return (.daily, businessHoursFormatted)
            } ?? []

        case .weekendDifferent:
            return generateWeekdayTimeTable()

        case .sundayDifferent:
            return generateOnlySundayDifferentTable()

        case .allDifferent:
            return generateTimeTable()
        }
    }

    /**
     Calculates the closed area values `[(Double, Double)]` around a given date (including the day before and day after).

     - Note: The goal is to get closed areas of given date. This methode returns also closed areas of the day before and the day after but those might not be complete. This could be the case if the day before yesterday has over night opening hours.

     - Parameters:
        - date: The `Date` we want to know the closed areas as unix time stamps.
        - returns: Array of tuple of unix time stamps where first marks start of a closed area and one
     */
    public func getClosedAreas(around date: Date) -> [(Double, Double)] {
        if isEmpty || is247 { return [] }

        let calendar = Calendar(identifier: .gregorian)
        let weekday = calendar.component(.weekday, from: date)

        let rulesPerDay = self.rulesPerDay

        // Determining the closing time for each day
        switch weekday {
        case 1: // Sunday
            return retrieveClosingTimes(for: [.friday, .saturday, .sunday, .monday, .tuesday], basedOn: rulesPerDay, at: date)

        case 2: // Monday
            return retrieveClosingTimes(for: [.saturday, .sunday, .monday, .tuesday, .wednesday], basedOn: rulesPerDay, at: date)

        case 3: // Tuesday
            return retrieveClosingTimes(for: [.sunday, .monday, .tuesday, .wednesday, .thursday], basedOn: rulesPerDay, at: date)

        case 4: // Wednesday
            return retrieveClosingTimes(for: [.monday, .tuesday, .wednesday, .thursday, .friday], basedOn: rulesPerDay, at: date)

        case 5: // Thursday
            return retrieveClosingTimes(for: [.tuesday, .wednesday, .thursday, .friday, .saturday], basedOn: rulesPerDay, at: date)

        case 6: // Friday
            return retrieveClosingTimes(for: [.wednesday, .thursday, .friday, .saturday, .sunday], basedOn: rulesPerDay, at: date)

        case 7: // Saturday
            return retrieveClosingTimes(for: [.thursday, .friday, .saturday, .sunday, .monday], basedOn: rulesPerDay, at: date)

        default:
            return []
        }
    }

    /**
     Retrieves the `OpeningRules` of each given day and converts them to unix times (`[(Double, Double)]`).
     For over night opening hours we need to get `OpeningRules` for one day before and one day after the desired day.

     - Parameters:
        - days: Array of 3 weekdays (`Days`). The middle one has to be the weekday we are looking to get the closed areas for. The first has to be one day earlier and the last one day after.
        - rules: Rules need to be the output of `rulesPerDay`.
        - date: The date to calculate the closing times for
     - Returns: An array of `Double` tuples where the first `Double` marks the start of a closed area as unix time and second marks the end `[(Double, Double)]`
     */
    private func retrieveClosingTimes(for days: [PCPOICommonOpeningHours.Rules.PCPOIDays], basedOn rules: [PCPOICommonOpeningHours.Rules.PCPOIDays: [(IndexSet, PCPOICommonOpeningHours.Rules.PCPOIAction)]], at date: Date) -> [(Double,Double)] {
        let oneDay: Double = 24 * 60 * 60
        // dates for each given weekday (`days`)
        let dates = [date.addingTimeInterval(-oneDay*2), date.addingTimeInterval(-oneDay), date, date.addingTimeInterval(oneDay), date.addingTimeInterval(oneDay*2)]

        var openingValues = [(Double, Double)]()
        var closedValues = [(Double, Double)]()

        // Retrieve all opening and closed values of rules for each day
        for i in 0..<days.count {
            if let dayRules = rules[days[i]] {
                dayRules.forEach {
                    let array = $0.0.map { Double($0) }
                    guard let start = array.first,
                          let end = array.last,
                          let startTime = dates[i].timeIntervalSince1970(atMinutes: Int(start)),
                          let endTime = dates[i].timeIntervalSince1970(atMinutes: Int(end))
                    else { return }

                    switch $0.1 {
                    case .open:
                        openingValues.append((startTime, endTime))

                    case .close:
                        closedValues.append((startTime, endTime))
                    }
                }
            }
        }

        // Making sure openingHours are in the right order
        openingValues.sort { $0.0 < $1.0 }

        // OpeningHours need to be converted to closed areas
        let startDate = date.addingTimeInterval(-oneDay*2).today // startDate is yesterday 00:00 of date
        let endDate = date.addingTimeInterval(3 * oneDay).today // endDate tomorrow 24:00 of date
        var convertedOpeningValues = invert(openingValues, startDate: startDate, endDate: endDate)

        // Add closedValues to converted OpeningHours
        convertedOpeningValues.append(contentsOf: closedValues)

        // Making sure all the closed values are in the right order
        convertedOpeningValues.sort { $0.0 < $1.0 }

        return combine(convertedOpeningValues)
    }

    /**
        Inverts `OpeningHours` of a day and returns closed values.
     */
    private func invert(_ openingValues: [(Double, Double)], startDate: Date, endDate: Date) -> [(Double, Double)] {
        var convertedValues = [(Double, Double)]()
        var lastEndValue = 0.0

        openingValues.forEach {
            // add first closed area from startDate to beginning of opening hours
            if convertedValues.isEmpty {
                convertedValues.append((startDate.timeIntervalSince1970, $0.0))
            } else {
                convertedValues.append((lastEndValue, $0.0))
            }

            // add last closed area
            if let last = openingValues.last, $0 == last && endDate.timeIntervalSince1970 > $0.1 {
                convertedValues.append(($0.1, endDate.timeIntervalSince1970))
            }

            lastEndValue = $0.1
        }

        return convertedValues
    }

    /**
     Combines closed area values where end value is equal to start value of next closed area and gets rid of overlapping closed areas.

     - Returns: Returns combined closeadAreas of input.
     */
    private func combine(_ closedAreas: [(Double, Double)]) -> [(Double, Double)] {
        var newClosedAreas = [(Double, Double)]()
        for i in 0..<closedAreas.count {
            // add first closed area
            if newClosedAreas.isEmpty {
                newClosedAreas.append(closedAreas[i])
            } else {
                guard let lastClosedArea = newClosedAreas.last else { break }
                if lastClosedArea.1 >= closedAreas[i].0 { // Checks if closedAreas are right next to each other
                    if lastClosedArea.1 < closedAreas[i].1 {
                        newClosedAreas[newClosedAreas.count - 1].1 = closedAreas[i].1
                    }
                } else {
                    newClosedAreas.append(closedAreas[i])
                }
            }
        }

        return newClosedAreas
    }

    public func getOpeningHours(for date: Date) -> POIKit.OpeningHoursValue { // we take a date here but we are just looking for the day
        let day = weekDayOfDate(date)
        switch openingHoursType {
        case .open247:
            return .open247

        case .allEqual:
            guard isOpenEveryDay else { return .closed }
            return first?.timespans?.compactMap {
                let minutes = $0.stringToMinutes()
                var to = minutes.to
                if to > POIKitConstants.dayInMinutes {
                    to -= POIKitConstants.dayInMinutes
                }

                if isAlwaysOpenSpecialCase(from: minutes.from, to: to) { // 00:00 - 23:59 - equals open247
                    return .wholeDay
                }

                let businessHours = "\(self.minutesToTime(minutes.from, from: true)) – \(self.minutesToTime(to))"
                let businessHoursFormatted: POIKit.OpeningHoursValue = $0.from == "0" && $0.to == "0" ? .open247 : .time(value: businessHours)
                return businessHoursFormatted
                }.first ?? .closed

        case .weekendDifferent:
            if PCPOICommonOpeningHours.Rules.PCPOIDays.weekdays.contains(day) {
                return self.generateWeekdayTimeTable()[0].1
            }
            return self.generateWeekdayTimeTable()[1].1

        case .sundayDifferent:
            if (PCPOICommonOpeningHours.Rules.PCPOIDays.weekdays.contains(day) || day == .saturday) {
                return self.generateWeekdayTimeTable()[0].1
            }
            return self.generateWeekdayTimeTable()[1].1

        case .allDifferent:
            let sortedRulesPerDay = rulesPerDay.sorted(by: { $0.key < $1.key })
            guard let rules = sortedRulesPerDay.first(where: { $0.key == day })
                else { return .closed }
            let openingHoursForDay: [TimeFrame] = applyRules(rules.value)?.rangeView.map(mapTimesRangeToOpeningHoursString) ?? []
            if openingHoursForDay.isEmpty {
                return .closed
            }
            return checkAlwaysOpenSpecialCase(timeFrames: openingHoursForDay)
        }
    }

    // Helper
    private func is12HoursFormat(_ locale: Locale? = nil) -> Bool {
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale ?? Locale.current)
        return formatString?.contains("a") ?? false
    }

    private func weekDayOfDate(_ date: Date) -> PCPOICommonOpeningHours.Rules.PCPOIDays {
        let days: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let weekday = Calendar.current.component(.weekday, from: date)
        return days[weekday - 1]
    }

    public func minutesToTime(_ minutes: Int, from: Bool = false, locale: Locale? = nil) -> String {
        let (hour, minute) = (minutes / 60, minutes % 60)

        if (hour == 24 || hour == 0) && minute == 0 {
            return is12HoursFormat(locale) ? "12:00 AM" : from ? "00:00" : "24:00"
        } else {
            let dateAsString = "\(hour):\(minute)"
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "HH:mm"

            let date = dateFormatter.date(from: dateAsString)
            dateFormatter.dateFormat = is12HoursFormat(locale) ? "h:mm a" : "HH:mm"

            guard let formattedDate = date else { return "" }
            return dateFormatter.string(from: formattedDate)
        }
    }
}
