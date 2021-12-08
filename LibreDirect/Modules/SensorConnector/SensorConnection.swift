//
//  SensorConnection.swift
//  LibreDirect
//

import Combine
import CoreBluetooth
import Foundation

typealias SensorConnectionHandler = (_ update: SensorConnectorUpdate) -> Void

// MARK: - SensorConnection

protocol SensorConnection {
    var updatesHandler: SensorConnectionHandler? { get }

    func pairSensor(updatesHandler: @escaping SensorConnectionHandler)
    func connectSensor(sensor: Sensor, updatesHandler: @escaping SensorConnectionHandler)
    func disconnectSensor()
}

extension SensorConnection {
    func sendUpdate(connectionState: SensorConnectionState) {
        Log.info("ConnectionState: \(connectionState.description)")
        updatesHandler?(SensorConnectionStateUpdate(connectionState: connectionState))
    }

    func sendUpdate(sensor: Sensor?) {
        Log.info("Sensor: \(sensor?.description ?? "-")")
        updatesHandler?(SensorUpdate(sensor: sensor))
    }

    func sendUpdate(transmitter: Transmitter) {
        Log.info("Transmitter: \(transmitter.description)")
        updatesHandler?(SensorTransmitterUpdate(transmitter: transmitter))
    }

    func sendUpdate(age: Int, state: SensorState) {
        Log.info("SensorAge: \(age.description)")
        updatesHandler?(SensorStateUpdate(sensorAge: age, sensorState: state))
    }

    func sendUpdate(nextReading: SensorReading) {
        Log.info("NextReading: \(nextReading)")
        updatesHandler?(SensorReadingUpdate(nextReading: nextReading))
    }

    func sendUpdate(trendReadings: [SensorReading] = [], historyReadings: [SensorReading] = []) {
        Log.info("SensorTrendReadings: \(trendReadings)")
        Log.info("SensorHistoryReadings: \(historyReadings)")
        updatesHandler?(SensorReadingUpdate(nextReading: trendReadings.last, trendReadings: trendReadings, historyReadings: historyReadings))
    }

    func sendUpdate(error: Error?) {
        guard let error = error else {
            return
        }

        if let errorCode = CBError.Code(rawValue: (error as NSError).code) {
            sendUpdate(errorCode: errorCode.rawValue, errorIsCritical: errorCode.rawValue == 7)
        } else {
            sendUpdate(errorMessage: error.localizedDescription)
        }
    }

    func sendUpdate(errorMessage: String) {
        Log.error("ErrorMessage: \(errorMessage)")
        updatesHandler?(SensorErrorUpdate(errorMessage: errorMessage))
    }

    func sendUpdate(errorCode: Int, errorIsCritical: Bool = false) {
        Log.error("ErrorCode: \(errorCode)")
        updatesHandler?(SensorErrorUpdate(errorCode: errorCode, errorIsCritical: errorIsCritical))
    }

    func sendMissedUpdate() {
        Log.error("Missed update")
        updatesHandler?(SensorReadingUpdate(nextReading: nil))
    }
}
