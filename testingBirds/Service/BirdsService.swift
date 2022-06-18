//
//  BirdsService.swift
//  testingBirds
//
//  Created by Тоха on 18.06.2022.
//

import Foundation
import UIKit

protocol SocketDelegate: AnyObject {
    func socketDataReceived(result: String?)
    func receivedNil()
}

protocol BirdsService: AnyObject {
    func getBirdInfo()
}

final class BirdsServiceImpl: NSObject, BirdsService {
    
    
    
    static private let HOST = "192.168.1.8"
    static private let PORT: UInt32 = 1488
    private let bytesLength = 2048
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    public var isOpen: Bool = false
    weak var delegate: SocketDelegate?
    
    override init() {
        super.init()
    }
    
    //1
    public func connect(){
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            BirdsServiceImpl.HOST as CFString,
            BirdsServiceImpl.PORT,
            &readStream,
            &writeStream)
        
        
        //store retained references
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        //run a loop
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        //open flood gates
        inputStream.open()
        outputStream.open()
        
        isOpen = true
    }
    
    private func stopSession() {
        inputStream.close()
        outputStream.close()
    }
    
    private func send(message: String) {
        let data = message.data(using: .utf8)!
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            print(data.count)
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    private func send(picture: Data) {
        
        picture.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: Data.self) else {
                print("Error joining chat")
                return
            }
            print(picture.count)
            outputStream.write(pointer, maxLength: picture.count)
        }
    }
    
    func getBirdInfo() {
        send(message: "cat")
        if let imageData = UIImage(named: "Cat03")?.jpegData(compressionQuality: 1.0) {
            send(picture: imageData)
        }
        send(message: "endOfCat")
    }
}

extension BirdsServiceImpl: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("The end of the stream has been reached.")
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesLength)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: bytesLength)
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                if message == "disconecting" {
                    stopSession()
                } else {
                    delegate?.socketDataReceived(result: message)
                }
            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> String? {
        guard
            let stringArray = String(
                bytesNoCopy: buffer,
                length: length,
                encoding: .utf8,
                freeWhenDone: true)?.components(separatedBy: ":"),
            let message = stringArray.last
        else {
            return nil
        }
        return message
    }
}
