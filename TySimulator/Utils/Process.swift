//
//  Process.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Foundation

extension Process {
    class func output(launchPath: String, arguments: [String], directoryPath: URL? = nil) -> String {
        let data = outputData(launchPath: launchPath, arguments: arguments, directoryPath: directoryPath)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    class func outputData(launchPath: String, arguments: [String], directoryPath: URL? = nil) -> Data {
        let output = Pipe()
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = output
        
        if let path = directoryPath?.removeTrailingSlash?.path {
            task.currentDirectoryPath = path
        }
        
        task.launch()
        
        // For some reason [task waitUntilExit]; does not return sometimes. Therefore this rather hackish solution:
        var count = 0
        while task.isRunning && count < 10 {
            Thread.sleep(forTimeInterval: 0.1)
            count += 1
        }
        
        return output.fileHandleForReading.readDataToEndOfFile()
    }
    
    @discardableResult
    class func execute(_ script: String) -> String {
        let scriptCLI = Script.transformedScript(script)
        log.info("run script: \(scriptCLI)")
        return output(launchPath: "/bin/sh", arguments: ["-c", scriptCLI])
    }
    
}
