//
//  MuFile.swift
//  MuseSky
//
//  Created by warren on 9/23/19.
//  Copyright © 2019 Muse. All rights reserved.
//

import UIKit
import Compression
import ZIPFoundation

class MuFile {
    
    static let shared = MuFile()
    let fileManager = FileManager.default
    let docURL : URL!
    var fileURLs : [URL]!

    init() {
        docURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURLs = fileManager.contentsOf(ext:nil)
        printFileURLs()
    }
    func printFileURLs() {
        for url in fileURLs {
            print(url)
        }
    }
    func saveFile(_ name: String, script:String) {
        let filename = docURL.appendingPathComponent(name)
        do {
            try script.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
    }
    func saveFile(_ name: String, image:UIImage) -> Bool {

        let filename = docURL.appendingPathComponent(name)

        do {
            if name.hasSuffix("jpg") {
                if let data = image.jpegData(compressionQuality: 1)  {
                    try data.write(to:filename)
                }

            } else {
                if let data = image.pngData() {
                    try data.write(to:filename)
                }
            }
        }
        catch {
            print(error)
            return false
        }
        return true
    }
    func saveFile(_ name: String, data:Data) -> Bool {

        let filename = docURL.appendingPathComponent(name)

        do { try data.write(to:filename) }

        catch {
            print(error)
            return false
        }
        return true
    }


    func decompress(_ data: Data) -> String {

        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return String(decoding: Data(bytes: buffer, count:read), as: UTF8.self)
        }) as String
        buffer.deallocate()
        return result
    }

    /// see https://github.com/weichsel/ZIPFoundation
    func zipArchive() {

        let fileManager = FileManager()
        let currentWorkingPath = fileManager.currentDirectoryPath
        var sourceURL = URL(fileURLWithPath: currentWorkingPath)
        sourceURL.appendPathComponent("file.txt")
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.appendPathComponent("archive.zip")
        do {
            try fileManager.zipItem(at: sourceURL, to: destinationURL)
        } catch {
            print("Creation of ZIP archive failed with error:\(error)")
        }
    }
    func unzipArchive() {
    
        let fileManager = FileManager()
        let currentWorkingPath = fileManager.currentDirectoryPath
        var sourceURL = URL(fileURLWithPath: currentWorkingPath)
        sourceURL.appendPathComponent("archive.zip")
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.appendPathComponent("directory")
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }
}
