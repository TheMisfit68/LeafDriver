
// MARK: - VehicleInfo
struct VehicleInfo: Codable {
    let vin: String
    let dcmid: String
    let simid: String
    let naviid: String
    let encryptedNaviid: String
    let msn: String
    let lastVehicleLoginTime: String
    let userVehicleBoundTime: String
    let lastDcmUseTime: String
    let nonaviFlg: String
    let carName: String
    let carImage: String

    enum CodingKeys: String, CodingKey {
        case vin = "VIN"
        case dcmid = "DCMID"
        case simid = "SIMID"
        case naviid = "NAVIID"
        case encryptedNaviid = "EncryptedNAVIID"
        case msn = "MSN"
        case lastVehicleLoginTime = "LastVehicleLoginTime"
        case userVehicleBoundTime = "UserVehicleBoundTime"
        case lastDcmUseTime = "LastDCMUseTime"
        case nonaviFlg = "NonaviFlg"
        case carName = "CarName"
        case carImage = "CarImage"
    }
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let profile: Profile

    enum CodingKeys: String, CodingKey {
        case profile = "profile"
    }
}

// MARK: - Profile
struct Profile: Codable {
    let vin: String
    let gdcUserId: String
    let gdcPassword: String
    let encAuthToken: String
    let dcmId: String
    let nickname: String
    let modelyear: String

    enum CodingKeys: String, CodingKey {
        case vin = "vin"
        case gdcUserId = "gdcUserId"
        case gdcPassword = "gdcPassword"
        case encAuthToken = "encAuthToken"
        case dcmId = "dcmId"
        case nickname = "nickname"
        case modelyear = "modelyear"
    }
}

// MARK: - VehicleInfoList
struct VehicleInfoList: Codable {
    let vehicleInfo: [VehicleInfoElement]
    let vehicleInfoListVehicleInfo: [VehicleInfoElement]

    enum CodingKeys: String, CodingKey {
        case vehicleInfo = "VehicleInfo"
        case vehicleInfoListVehicleInfo = "vehicleInfo"
    }
}

// MARK: - VehicleInfoElement
struct VehicleInfoElement: Codable {
    let nickname: String
    let telematicsEnabled: String
    let vin: String
    let customSessionid: String?

    enum CodingKeys: String, CodingKey {
        case nickname = "nickname"
        case telematicsEnabled = "telematicsEnabled"
        case vin = "vin"
        case customSessionid = "custom_sessionid"
    }
}
