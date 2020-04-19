// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let encryptionKey = try EncryptionKey(json)

import Foundation

// MARK: - EncryptionKey
struct EncryptionKey: Codable {
    let status: Int
    let message, baseprm: String
}

// MARK: EncryptionKey convenience initializers and mutators

extension EncryptionKey {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EncryptionKey.self, from: data)
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
        message: String? = nil,
        baseprm: String? = nil
    ) -> EncryptionKey {
        return EncryptionKey(
            status: status ?? self.status,
            message: message ?? self.message,
            baseprm: baseprm ?? self.baseprm
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
