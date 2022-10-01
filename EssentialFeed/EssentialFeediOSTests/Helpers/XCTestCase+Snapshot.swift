//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 29/09/2022.
//

import XCTest

extension XCTestCase {
    
    func assert(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(snapshot: snapshot,file: file,line: line)
        
        let snapshotURL = makeSnapshotURL(named: name,file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(snapshot: snapshot,file: file,line: line)
        
        let snapshotURL = makeSnapshotURL(named: name,file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(),withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String,file: StaticString = #filePath) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(
        snapshot: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
}