//
//  main.swift
//  ImageFeed
//
//  Created by Kirill Sklyarov on 19.02.2024.
//

//import Foundation
//import UIKit
//
//enum AppReset {
//    static func resetKeychain() {
//        let secClasses = [
//            kSecClassGenericPassword as String,
//            kSecClassInternetPassword as String,
//            kSecClassCertificate as String,
//            kSecClassKey as String,
//            kSecClassIdentity as String
//        ]
//        for secClass in secClasses {
//            let query = [kSecClass as String: secClass]
//            SecItemDelete(query as CFDictionary)
//        }
//    }
//}
//
//_ = autoreleasepool {
//    if ProcessInfo().arguments.contains("--Reset") {
//        AppReset.resetKeychain()
//    }
//    _ = UIApplicationMain(
//        CommandLine.argc,
//        UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to:
//                                                                    UnsafeMutablePointer?.self, capacity: Int(CommandLine.argc)),
//        nil,
//        NSStringFromClass(AppDelegate.self)
//    )
//}
