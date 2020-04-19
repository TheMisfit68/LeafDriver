// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let voltLabel = try VoltLabel(json)

import Foundation

// MARK: - VoltLabel
struct VoltLabel: Codable {
    let highVolt, lowVolt: String

    enum CodingKeys: String, CodingKey {
        case highVolt = "HighVolt"
        case lowVolt = "LowVolt"
    }
}

// MARK: VoltLabel convenience initializers and mutators

extension VoltLabel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(VoltLabel.self, from: data)
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
        highVolt: String? = nil,
        lowVolt: String? = nil
    ) -> VoltLabel {
        return VoltLabel(
            highVolt: highVolt ?? self.highVolt,
            lowVolt: lowVolt ?? self.lowVolt
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
