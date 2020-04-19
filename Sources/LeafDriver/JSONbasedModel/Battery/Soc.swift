// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let soc = try Soc(json)

import Foundation

// MARK: - Soc
struct Soc: Codable {
    let value: String

    enum CodingKeys: String, CodingKey {
        case value = "Value"
    }
}

// MARK: Soc convenience initializers and mutators

extension Soc {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Soc.self, from: data)
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
        value: String? = nil
    ) -> Soc {
        return Soc(
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
