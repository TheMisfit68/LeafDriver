// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let session = try Session(json)

import Foundation

// MARK: - Session
struct Session: Codable {
    let status: Int
    let sessionID: String
    let vehicleInfoList: VehicleInfoList
    let vehicle: Vehicle
    let encAuthToken: String
    let customerInfo: CustomerInfo
    let userInfoRevisionNo, ngTapUpdatebtn, timeoutUpdateAnime, g1Lw: String
    let g1Li, g1Lt, g1Uw, g1UI: String
    let g1Ut, g2Lw, g2Li, g2Lt: String
    let g2Uw, g2UI, g2Ut, resultKey: String

    enum CodingKeys: String, CodingKey {
        case status
        case sessionID = "sessionId"
        case vehicleInfoList = "VehicleInfoList"
        case vehicle
        case encAuthToken = "EncAuthToken"
        case customerInfo = "CustomerInfo"
        case userInfoRevisionNo = "UserInfoRevisionNo"
        case ngTapUpdatebtn, timeoutUpdateAnime
        case g1Lw = "G1Lw"
        case g1Li = "G1Li"
        case g1Lt = "G1Lt"
        case g1Uw = "G1Uw"
        case g1UI = "G1Ui"
        case g1Ut = "G1Ut"
        case g2Lw = "G2Lw"
        case g2Li = "G2Li"
        case g2Lt = "G2Lt"
        case g2Uw = "G2Uw"
        case g2UI = "G2Ui"
        case g2Ut = "G2Ut"
        case resultKey
    }
}

// MARK: Session convenience initializers and mutators

extension Session {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Session.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        status: Int? = nil,
        sessionID: String? = nil,
        vehicleInfoList: VehicleInfoList? = nil,
        vehicle: Vehicle? = nil,
        encAuthToken: String? = nil,
        customerInfo: CustomerInfo? = nil,
        userInfoRevisionNo: String? = nil,
        ngTapUpdatebtn: String? = nil,
        timeoutUpdateAnime: String? = nil,
        g1Lw: String? = nil,
        g1Li: String? = nil,
        g1Lt: String? = nil,
        g1Uw: String? = nil,
        g1UI: String? = nil,
        g1Ut: String? = nil,
        g2Lw: String? = nil,
        g2Li: String? = nil,
        g2Lt: String? = nil,
        g2Uw: String? = nil,
        g2UI: String? = nil,
        g2Ut: String? = nil,
        resultKey: String? = nil
    ) -> Session {
        return Session(
            status: status ?? self.status,
            sessionID: sessionID ?? self.sessionID,
            vehicleInfoList: vehicleInfoList ?? self.vehicleInfoList,
            vehicle: vehicle ?? self.vehicle,
            encAuthToken: encAuthToken ?? self.encAuthToken,
            customerInfo: customerInfo ?? self.customerInfo,
            userInfoRevisionNo: userInfoRevisionNo ?? self.userInfoRevisionNo,
            ngTapUpdatebtn: ngTapUpdatebtn ?? self.ngTapUpdatebtn,
            timeoutUpdateAnime: timeoutUpdateAnime ?? self.timeoutUpdateAnime,
            g1Lw: g1Lw ?? self.g1Lw,
            g1Li: g1Li ?? self.g1Li,
            g1Lt: g1Lt ?? self.g1Lt,
            g1Uw: g1Uw ?? self.g1Uw,
            g1UI: g1UI ?? self.g1UI,
            g1Ut: g1Ut ?? self.g1Ut,
            g2Lw: g2Lw ?? self.g2Lw,
            g2Li: g2Li ?? self.g2Li,
            g2Lt: g2Lt ?? self.g2Lt,
            g2Uw: g2Uw ?? self.g2Uw,
            g2UI: g2UI ?? self.g2UI,
            g2Ut: g2Ut ?? self.g2Ut,
            resultKey: resultKey ?? self.resultKey
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
