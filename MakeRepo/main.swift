#!/usr/bin/swift

//
//  main.swift
//  MakeRepo
//
//  Created by Garric Nahapetian on 11/25/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Foundation

// MARK: - Globals

let usrLocalBinPath = "/usr/local/bin"

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

func askForDestinationPath() -> String {
    print("💾  Where would you like to save the program? Type a file path and hit return. Leave empty and hit return to save at path: \(usrLocalBinPath) .")

    let fileManager = FileManager.default
    let path = readLine() ?? ""

    guard !path.isEmpty else {
        return "\(usrLocalBinPath)"
    }

    guard fileManager.fileExists(atPath: path) else {
        printError("That path doesn't exist. Try again.")
        return askForDestinationPath()
    }

    return path
}

func askForUsername() -> String {
    print("👤  What is your GitHub username? Type your username and hit return. Your GitHub Username is required. Visit https://developer.github.com/v3/repos/#create for info.")

    let username = readLine()

    guard let _username = username else {
        return askForUsername()
    }

    return _username
}

func askForToken() -> String {
    print("🔑 What is your API Token? Type the token and hit return. Your GitHub API Token with \"repo\" scope is required. Visit https://developer.github.com/v3/auth/#basic-authentication for info.")

    let token = readLine()

    guard let _token = token else {
        return askForToken()
    }

    return _token
}

func shouldProceed() -> Bool {
    print("⚒ Proceed? Type Y for yes or N for no then hit return.")

    let answer = readLine() ?? ""
    switch answer.lowercased() {
    case "y":
        return true
    case "n":
        return false
    default:
        printError("Invalid response. Enter either Y, y, N, or n.")
        return shouldProceed()
    }
}

func performCommand(description: String, command: () throws -> Void) rethrows {
    print("👉  \(description) ...")
    try command()
    print("✅  Done")
}

func generateExecutableFromFile(atPath path: String) throws {
    let generateExecutableTask = Process()
    generateExecutableTask.launchPath = "/bin/bash"
    generateExecutableTask.arguments = [
        "-c",
        "xcrun swiftc \(path)"
    ]
    generateExecutableTask.launch()
    generateExecutableTask.waitUntilExit()
}

// MARK: - Program

print("👋🏽  Welcome to MakeRepo  👋🏽")
print("💥  This Swift program will generate another Swift program that you can use to easily create GitHub repos from the command line. 💥")

let destinationPath = askForDestinationPath()
let username = askForUsername()
let token = askForToken()

print("---")
print(" MakeRepo will now generate a Swift program with the following parameters:")
print("💾  Destination: \(destinationPath)")
print("👤  Username: \(username)")
print("🔑  API Token: \(token)")
print("---")

guard shouldProceed() else {
    exit(0)
}

do {
    let fileManager = FileManager.default
    let currentDirectoryPath = fileManager.currentDirectoryPath
    let templatePath = "\(currentDirectoryPath)/template.swift"
    let temporaryDirectoryPath = "\(currentDirectoryPath)/temp"
    let temporaryFilePath = "\(temporaryDirectoryPath)/_makerepo.swift"
    let finalFilePath = "\(currentDirectoryPath)/_makerepo.swift"
    let executableFilePath = "\(currentDirectoryPath)/_makerepo"

    // TODO: - Why does this not beed to be marked with try?
    performCommand(description: "Removing any previous temporary directory ") {
        try? fileManager.removeItem(atPath: temporaryDirectoryPath)
    }

    try performCommand(description: "Making temporary directory at path: \(temporaryDirectoryPath)") {
        try fileManager.createDirectory(
            atPath: temporaryDirectoryPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
    }

    try performCommand(description: "Copying template at path: \(templatePath) to path: \(temporaryFilePath)") {
        try fileManager.copyItem(atPath: templatePath, toPath: temporaryFilePath)
    }


    try performCommand(description: "Filling in the template") {
        let templateContents = try String(contentsOfFile: temporaryFilePath)
        let finalContents = templateContents
            .replacingOccurrences(of: "{USERNAME}", with: username)
            .replacingOccurrences(of: "{TOKEN}", with: token)

        try finalContents.write(
            toFile: finalFilePath,
            atomically: false,
            encoding: .utf8
        )
    }

    try performCommand(description: "Generating executable from file at path: \(finalFilePath)") {
        try generateExecutableFromFile(atPath: finalFilePath)
    }

    try performCommand(description: "Moving executable to path: \(destinationPath)") {
        try fileManager.moveItem(
            atPath: executableFilePath,
            toPath: "\(destinationPath)/makerepo"
        )
    }

    try performCommand(description: "Removing temporary files and directories") {
        try fileManager.removeItem(atPath: temporaryDirectoryPath)
        try fileManager.removeItem(atPath: finalFilePath)
    }

    print("All done! 🎉")
    if destinationPath == usrLocalBinPath {
        print("You can now run makeRepo from anywhere on the command line to instantly make remote repos on your GitHub!")
    } else {
        print("You can now run makeRepo from this directory. To run the command from any directory, move makeRepo to path: \(usrLocalBinPath) .")
    }
} catch {
    print(error)
}
