
//
//  FreeAPS.swift
//  LibreDirect
//

import Combine
import Foundation

func appGroupSharingMiddleware() -> Middleware<AppState, AppAction> {
    return appGroupSharingMiddleware(service: AppGroupSharingService())
}

private func appGroupSharingMiddleware(service: AppGroupSharingService) -> Middleware<AppState, AppAction> {
    return { _, action, _ in
        switch action {
        case .addGlucose(glucose: let glucose):
            service.addGlucose(glucoseValues: [glucose])

        default:
            break
        }

        return Empty().eraseToAnyPublisher()
    }
}

// MARK: - FreeAPSService

private class AppGroupSharingService {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    func addGlucose(glucoseValues: [Glucose]) {
        let sharedValues = glucoseValues.map { $0.toFreeAPS() }

        Log.info("Shared values, values: \(sharedValues)")

        guard let sharedValuesJson = try? JSONSerialization.data(withJSONObject: sharedValues) else {
            return
        }

        Log.info("Shared values, json: \(sharedValuesJson)")

        UserDefaults.shared.latestReadings = sharedValuesJson
    }
}

private extension Glucose {
    func toFreeAPS() -> [String: Any] {
        let date = "/Date(" + Int64(floor(self.timestamp.toMillisecondsAsDouble() / 1000) * 1000).description + ")/"

        let freeAPSGlucose: [String: Any] = [
            "Value": self.glucoseValue,
            "Trend": self.trend.toFreeAPS(),
            "DT": date,
            "direction": self.trend.toFreeAPSX()
        ]

        return freeAPSGlucose
    }
}

private extension SensorTrend {
    func toFreeAPS() -> Int {
        switch self {
        case .rapidlyRising:
            return 1
        case .fastRising:
            return 2
        case .rising:
            return 3
        case .constant:
            return 4
        case .falling:
            return 5
        case .fastFalling:
            return 6
        case .rapidlyFalling:
            return 7
        case .unknown:
            return 0
        }
    }
    
    func toFreeAPSX() -> String {
        switch self {
        case .rapidlyRising:
            return "DoubleUp"
        case .fastRising:
            return "SingleUp"
        case .rising:
            return "FortyFiveUp"
        case .constant:
            return "Flat"
        case .falling:
            return "FortyFiveDown"
        case .fastFalling:
            return "SingleDown"
        case .rapidlyFalling:
            return "DoubleDown"
        case .unknown:
            return "NONE"
        }
    }
}
