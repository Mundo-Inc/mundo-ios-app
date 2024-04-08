//
//  TwilioConversation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation

/// Abstract:
///     A model that represents a Conversation - including its sid and all the information that is needed on your app's user interface.
///
/// Usage:
/// This type does not persist any information, it belongs to the business layer, and is intended to be used as a business model.
///     For its equivalent on the Persistance Layer see 'PersistentConversationDataItem'
///     For its equivalent on the TwilioClient see 'TCHConversation'
///
/// Use TCHAdapter to transform from 'TCHConversation'  model to 'Conversation'
///
struct Conversation {
    
    // sid = conversation identifier
    var sid: String
    //Add more properties as needed.
}
