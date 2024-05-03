//
//  ContactsService.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/18/23.
//

import Foundation
import Contacts

final class ContactsService {
    static let daysBetweenSync: Int = 20
    static let shared = ContactsService()
    
    private let store = CNContactStore()
    
    private init() {}
    
    /// Request access to the user's contacts
    private func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Fetch contacts from the user's address book
    private func fetchContacts(completion: @escaping (Result<[CNContact], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var contacts = [CNContact]()
            do {
                try self.store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
                DispatchQueue.main.async {
                    completion(.success(contacts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Sync contacts with server if access is granted and contactsLastSyncDate is checked
    func tryToSyncContacts() {
        requestAccess { accessGranted in
            guard accessGranted else { return }
            if let lastSyncDate = self.lastSyncDate, let daysFromLastSync = Calendar.current.dateComponents([.day], from: lastSyncDate, to: .now).day, daysFromLastSync < ContactsService.daysBetweenSync {
                return
            }
            
            self.fetchContacts { result in
                switch result {
                case .success(let data):
//                    if let first = success.first {
//                        for phoneNumber in first.phoneNumbers {
//                            print(phoneNumber)
//                        }
//                    }
                    
                    self.updateLastSyncDate()
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
}

/// Last synced date
extension ContactsService {
    var lastSyncDate: Date? {
        UserDefaults.standard.object(forKey: K.UserDefaults.contactsLastSyncDate) as? Date
    }
    
    func updateLastSyncDate() {
        UserDefaults.standard.set(Date(), forKey: K.UserDefaults.contactsLastSyncDate)
    }
}
