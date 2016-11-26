#!/usr/bin/swift

//
//  main.swift
//  MakeRepo
//
//  Created by Garric Nahapetian on 11/25/16.
//  Credit to John Sundell and SwiftPlate: https://github.com/JohnSundell/SwiftPlate
//

import Foundation

// MARK: - Globals

let usrLocalBinPath = "/usr/local/bin"

// MARK: - Functions

func printError(_ message: String) {
    print("👮  \(message)")
}

func askForDestinationPath() -> String {
    print("💾  Where would you like to save the tool? (Leave empty and hit return to save at path: \(usrLocalBinPath))")

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
    print("👤  What's your GitHub username? (Required: see https://developer.github.com/v3/repos/#create)")

    let username = readLine()

    guard let _username = username else {
        return askForUsername()
    }

    return _username
}

func askForToken() -> String {
    print("🔑 What's your API Token? (GitHub API Token with \"repo\" scope required: see https://developer.github.com/v3/auth/#basic-authentication)")

    let token = readLine()

    guard let _token = token else {
        return askForToken()
    }

    return _token
}

func shouldProceed() -> Bool {
    print("🚦 Proceed? Y (yes) or N (no)?")

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
    print("👉  \(description)...")
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

print("👋🏽  Welcome to the MakeRepo Generator 👋🏽")
print("💥  MakeRepo is a Command Line Tool for easily creating GitHub repos 💥")
print("💪🏽  This Generator will create the MakeRepo tool for you 💪🏽")

let destinationPath = askForDestinationPath() + "/makerepo"
let username = askForUsername()
let token = askForToken()

print("---")
print(" The Generator will now create the tool using the following parameters:")
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
    let secondaryFilePath = "\(currentDirectoryPath)/_makerepo.swift"
    let executableFilePath = "\(currentDirectoryPath)/_makerepo"

    performCommand(description: "Removing any previous temporary directory") {
        try? fileManager.removeItem(atPath: temporaryDirectoryPath)
    }

    try performCommand(description: "Making temporary directory at path") {
        try fileManager.createDirectory(
            atPath: temporaryDirectoryPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
    }

    try performCommand(description: "Copying the template") {
        try fileManager.copyItem(atPath: templatePath, toPath: temporaryFilePath)
    }


    try performCommand(description: "Filling in the template") {
        let templateContents = try String(contentsOfFile: temporaryFilePath)
        let finalContents = templateContents
            .replacingOccurrences(of: "{USERNAME}", with: username)
            .replacingOccurrences(of: "{TOKEN}", with: token)

        try finalContents.write(
            toFile: secondaryFilePath,
            atomically: false,
            encoding: .utf8
        )
    }

    try performCommand(description: "Generating executable from file") {
        try generateExecutableFromFile(atPath: secondaryFilePath)
    }

    try performCommand(description: "Moving executable to: \(destinationPath)") {
        try fileManager.moveItem(
            atPath: executableFilePath,
            toPath: "\(destinationPath)"
        )
    }

    try performCommand(description: "Removing temporary files and directories") {
        try fileManager.removeItem(atPath: temporaryDirectoryPath)
        try fileManager.removeItem(atPath: secondaryFilePath)
    }

    print("🎉  All done 🎉")
    if destinationPath == usrLocalBinPath + "/makerepo" {
        print("You can now run makerepo from anywhere on the command line to instantly make remote repos on your GitHub!")
    } else {
        print("You can now run ./makerepo from this directory. To run makerepo from any directory, move makeRepo to path: \(usrLocalBinPath) .")
    }
} catch {
    printError(error.localizedDescription)
}
