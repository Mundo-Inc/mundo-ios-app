//
//  SocketService.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/24/24.
//

import Foundation
import SocketIO

final class SocketService: ObservableObject {
    static let shared = SocketService()
    
    @Published var status: SocketIOStatus = .notConnected
    
    private let auth = Authentication.shared
    private let manager: SocketManager
    
    public let socket: SocketIOClient
    
    private var eventListeners: [Event: [(id: String, callback: NormalCallback)]] = [:]
    private let eventQueue = DispatchQueue(label: "\(K.ENV.BundleIdentifier).SocketService.eventQueue")
    
    private init() {
        let config: SocketIOClientConfiguration = [
            .compress,
            .reconnectWait(5),
            .reconnectWaitMax(10),
        ]
        
        self.manager = SocketManager(socketURL: URL(string: K.ENV.APIBaseURL)!, config: config)
        self.socket = self.manager.defaultSocket
        
        setupSocketEvents()
    }
    
    func request(for event: Event, callback: @escaping ([Any]) -> ()) -> Any {
        socket.emitWithAck(Event.request.rawValue, ["event": event.rawValue, "type": "ack"]).timingOut(after: 10) { result in
            callback(result)
        }
    }
    
    func request(for event: Event) {
        socket.emit(Event.request.rawValue, ["event": event.rawValue, "type": "emit"])
    }
    
    func addListener(for event: Event, id: String, callback: @escaping NormalCallback) {
        eventQueue.async {
            if self.eventListeners[event] == nil {
                self.eventListeners[event] = [(id, callback)]
                
                self.socket.on(event.rawValue) { data, ack in
                    self.eventListeners[event]?.forEach { $0.callback(data, ack) }
                }
            } else {
                self.eventListeners[event]!.append((id, callback))
            }
        }
    }
    
    func removeListener(for event: Event, id: String) {
        eventQueue.async {
            guard self.eventListeners[event] != nil else {
                self.socket.off(event.rawValue)
                return
            }
            
            self.eventListeners[event]!.removeAll { $0.id == id }
            
            if self.eventListeners[event]!.isEmpty {
                self.eventListeners.removeValue(forKey: event)
                self.socket.off(event.rawValue)
            }
        }
    }
    
    func connect() async {
        guard let token = await auth.getToken() else { return }
        
        self.manager.setConfigs([.extraHeaders(["Authorization": token])])
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    private func setupSocketEvents() {
        socket.on(clientEvent: .statusChange) { [weak self] data, ack in
            guard let self, let status = data.first as? SocketIOStatus else { return }
            
            DispatchQueue.main.async {
                self.status = status
            }
        }
    }
}

extension SocketService {
    enum Event: String {
        case earnings
        
        case request
    }
}

protocol SocketListener {
    func addSocketListener()
    func removeSocketListener()
}
