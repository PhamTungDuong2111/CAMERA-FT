import SwiftUI

public enum MediaType: String, Codable {
    case photo
    case video
}

public struct CapturedMedia: Identifiable, Codable, Equatable {
    public var id: String
    public var type: MediaType
    public var localFileName: String
    public var thumbnailFileName: String
    public var creationDate: Date
    public var templateId: String
    public var templateName: String
    public var verificationRecord: VerificationRecord?
    public var durationSeconds: Double? // For video
    public var fileSize: Int64
    
    public init(
        id: String = UUID().uuidString,
        type: MediaType = .photo,
        localFileName: String,
        thumbnailFileName: String,
        creationDate: Date = Date(),
        templateId: String = "",
        templateName: String = "",
        verificationRecord: VerificationRecord? = nil,
        durationSeconds: Double? = nil,
        fileSize: Int64 = 0
    ) {
        self.id = id
        self.type = type
        self.localFileName = localFileName
        self.thumbnailFileName = thumbnailFileName
        self.creationDate = creationDate
        self.templateId = templateId
        self.templateName = templateName
        self.verificationRecord = verificationRecord
        self.durationSeconds = durationSeconds
        self.fileSize = fileSize
    }
}
