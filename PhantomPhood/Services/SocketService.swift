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
    
    private var requests: [CTSEvent: [(id: String, callback: ([Any]) -> ())?]] = [:]
    private var eventListeners: [STCEvent: [(id: String, callback: NormalCallback)]] = [:]
    private let eventQueue = DispatchQueue(label: "\(K.ENV.BundleIdentifier).SocketService.eventQueue")
    
    private init() {
        let config: SocketIOClientConfiguration = [
            .compress,
            .reconnectWait(3),
            .reconnectWaitMax(5),
        ]
        
        self.manager = SocketManager(socketURL: URL(string: K.ENV.APIBaseURL)!, config: config)
        self.socket = self.manager.defaultSocket
        
        socket.on(clientEvent: .connect) { data, ack in
            if !self.requests.isEmpty {
                for (key, value) in self.requests {
                    guard !value.isEmpty else { return }
                    
                    if value.contains(where: { $0?.callback == nil }) {
                        switch key {
                        case .request(let event):
                            self.socket.emit(key.name, ["event": event.name, "type": SocketService.CTSEvent.ResponseType.emit.rawValue])
                        case .newMessage(let conversation, let content):
                            self.socket.emit(key.name, ["conversation": conversation, "content": content])
                        case .updateReadIndex(let conversation, let index):
                            self.socket.emit(key.name, ["conversation": conversation, "index": index])
                        }
                    } else {
                        switch key {
                        case .request(let event):
                            self.socket.emitWithAck(key.name, ["event": event.name, "type": SocketService.CTSEvent.ResponseType.ack.rawValue]).timingOut(after: 10) { result in
                                for cb in value {
                                    if let cb {
                                        cb.callback(result)
                                    }
                                }
                            }
                        case .newMessage(let conversation, let content):
                            self.socket.emitWithAck(key.name, ["conversation": conversation, "content": content]).timingOut(after: 10) { result in
                                for cb in value {
                                    if let cb {
                                        cb.callback(result)
                                    }
                                }
                            }
                        case .updateReadIndex(let conversation, let index):
                            self.socket.emitWithAck(key.name, ["conversation": conversation, "index": index]).timingOut(after: 10) { result in
                                for cb in value {
                                    if let cb {
                                        cb.callback(result)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        setupSocketEvents()
    }
    
    func request(for ctsEvent: CTSEvent, callback: @escaping ([Any]) -> (), id: String = UUID().uuidString) {
        guard socket.status == .connected else {
            if requests[ctsEvent] == nil {
                requests[ctsEvent] = [(id, callback)]
            } else if !requests[ctsEvent]!.contains(where: { $0?.id == id }) {
                requests[ctsEvent]!.append((id, callback))
            }
            
            return
        }
        
        switch ctsEvent {
        case .request(let event):
            socket.emitWithAck(ctsEvent.name, ["event": event.name, "type": SocketService.CTSEvent.ResponseType.ack.rawValue]).timingOut(after: 10) { result in
                callback(result)
            }
        case .newMessage(let conversation, let content):
            socket.emitWithAck(ctsEvent.name, ["conversation": conversation, "content": content]).timingOut(after: 10) { result in
                callback(result)
            }
        case .updateReadIndex(let conversation, let index):
            socket.emitWithAck(ctsEvent.name, ["conversation": conversation, "index": index]).timingOut(after: 10) { result in
                callback(result)
            }
        }
    }
    
    func request(for ctsEvent: CTSEvent) {
        guard socket.status == .connected else {
            if requests[ctsEvent] == nil {
                requests[ctsEvent] = [nil]
            } else if !requests[ctsEvent]!.contains(where: { $0 == nil }) {
                requests[ctsEvent]!.append(nil)
            }
            
            return
        }
        
        switch ctsEvent {
        case .request(let event):
            socket.emit(ctsEvent.name, ["event": event.name, "type": SocketService.CTSEvent.ResponseType.emit.rawValue])
        case .newMessage(let conversation, let content):
            socket.emit(ctsEvent.name, ["conversation": conversation, "content": content])
        case .updateReadIndex(let conversation, let index):
            socket.emit(ctsEvent.name, ["conversation": conversation, "index": index])
        }
    }
    
    func addListener(for event: STCEvent, id: String, callback: @escaping NormalCallback) {
        eventQueue.async {
            if self.eventListeners[event] == nil {
                self.eventListeners[event] = [(id, callback)]
                
                self.socket.on(event.name) { data, ack in
                    self.eventListeners[event]?.forEach { $0.callback(data, ack) }
                }
            } else {
                self.eventListeners[event]!.append((id, callback))
            }
        }
    }
    
    func removeListener(for event: STCEvent, id: String) {
        eventQueue.async {
            guard self.eventListeners[event] != nil else {
                self.socket.off(event.name)
                return
            }
            
            self.eventListeners[event]!.removeAll { $0.id == id }
            
            if self.eventListeners[event]!.isEmpty {
                self.eventListeners.removeValue(forKey: event)
                self.socket.off(event.name)
            }
        }
    }
    
    func connect() async {
        guard let token = try? await auth.getToken() else { return }
        
        self.manager.setConfigs([.extraHeaders(["Authorization": token])])
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    private func setupSocketEvents() {
        socket.on(clientEvent: .statusChange) { [weak self] data, ack in
            guard let self, let status = data.first as? SocketIOStatus else { return }
            
            if status == .connected {
                Task {
                    await ConversationManager.shared.getConversations()
                }
            }
            
            DispatchQueue.main.async {
                self.status = status
            }
        }
    }
}

extension SocketService {
    enum CTSEvent: Hashable {
        case request(event: RequestEvent)
        case newMessage(conversation: String, content: String)
        case updateReadIndex(conversation: String, index: Int)
        
        var name: String {
            switch self {
            case .request:
                "request"
            case .newMessage(_, _):
                "newMessage"
            case .updateReadIndex(_, _):
                "updateReadIndex"
            }
        }
        
        enum ResponseType: String {
            case emit
            case ack
        }
        
        enum RequestEvent: Hashable {
            case earnings
            
            var name: String {
                switch self {
                case .earnings:
                    "earnings"
                }
            }
        }
    }
    
    enum STCEvent: Hashable {
        case earnings
        case newMessage
        case updateReadIndex
        
        var name: String {
            switch self {
            case .earnings:
                "earnings"
            case .newMessage:
                "newMessage"
            case .updateReadIndex:
                "updateReadIndex"
            }
        }
    }
}

protocol SocketListener {
    func addSocketListener()
    func removeSocketListener()
}
