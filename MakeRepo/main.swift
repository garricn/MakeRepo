#!/usr/bin/swift

//
//  main.swift
//  MakeRepo
//
//  Created by Garric Nahapetian on 11/25/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Foundation

// MARK: - Extensions

extension String {
    var nonEmpty: String? {
        guard characters.count > 0 else {
            return nil
        }
        
        return self
    }
}

// MARK: - Functions

func printError(_ message: String) {
    print("👮  \(message)")
}


func askForOptionalInfo(question: String, questionSuffix: String = "You may leave this empty.") -> String? {
    print("\(question) \(questionSuffix)")
    return readLine()?.nonEmpty
}

func askForDestination() -> String {
    let destination = askForOptionalInfo(
        question: "📦  Where would you like to save the generated executable?",
        questionSuffix: "(Leave empty to use /usr/local/bin)"
        ) ?? "/usr/local/bin"
    
    let fileManager = FileManager.default
    
    guard fileManager.fileExists(atPath: destination) else {
        printError("That path doesn't exist. Try again.")
        return askForDestination()
    }
    
    return destination
}

// get username
// get api token
// spit out executable
// exe then just asks for repo name

// MARK: - Program

print("Welcome to the Add GitHub Repo Swift Script Generator")

let destination = askForDestination()

