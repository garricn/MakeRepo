#!/usr/bin/swift

/*
 *  MakeRepo: https://github.com/garricn/MakeRepo
 *
 *  makeRepo.swift
 *
 *  Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
*/

import Foundation

func createRepo(with name: String) throws {
    let process = Process()
    process.launchPath = "//bin/zsh"
    process.arguments = [
        "-c",
        "curl -u \"{USERNAME}:{TOKEN}\" https://api.github.com/user/repos -d '{\"name\":\"\(name)\"}'"
    ]
    process.launch()
    process.waitUntilExit()
}

print("👉  Enter name of repo then hit return")
if let repoName = readLine(), !repoName.isEmpty {
    do {
        try createRepo(with: repoName)
    } catch {
        print("Error: \(error)")
    }
    print("💎  Created repo named: \(repoName)")
    exit(0)
} else {
    print("❌  Error: Repo name required.")
    exit(0)
}
