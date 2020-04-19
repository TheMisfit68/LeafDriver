// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let profile = try Profile(json)

import Foundation

// MARK: - Profile
struct Profile: Codable {
    let vin, gdcUserid, gdcPassword, encAuthToken: String
    let dcmid, nickname, modelyear: String

    enum CodingKeys: String, CodingKey {
        case vin
        case gdcUserid = "gdcUserId"
        case gdcPassword, encAuthToken
        case dcmid = "dcmId"
        case nickname, modelyear
    }
}

// MARK: Profile convenience initializers and mutators

extension Profile {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Profile.self, from: data)
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
        vin: String? = nil,
        gdcUserid: String? = nil,
        gdcPassword: String? = nil,
        encAuthToken: String? = nil,
        dcmid: String? = nil,
        nickname: String? = nil,
        modelyear: String? = nil
    ) -> Profile {
        return Profile(
            vin: vin ?? self.vin,
            gdcUserid: gdcUserid ?? self.gdcUserid,
            gdcPassword: gdcPassword ?? self.gdcPassword,
            encAuthToken: encAuthToken ?? self.encAuthToken,
            dcmid: dcmid ?? self.dcmid,
            nickname: nickname ?? self.nickname,
            modelyear: modelyear ?? self.modelyear
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
