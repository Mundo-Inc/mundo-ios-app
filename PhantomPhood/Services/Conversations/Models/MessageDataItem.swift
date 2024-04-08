//
//  MessageDataItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation
import TwilioConversationsClient

struct MediaMessageProperties: Equatable {
    let mediaURL: URL?
    let messageSize: Int
    let uploadedSize: Int
}

enum MediaStatus: Int {
    case unknown, downloading, downloaded, error, uploading, uploaded
}

enum MessageDirection: Int, Codable {
    case incoming = 0, outgoing
}
