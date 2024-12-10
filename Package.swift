// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  WSDLService
//
//  Created by Milko Daskalov on 29.11.24.
//

import PackageDescription

let package = Package(
    name: "WSDLService",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WSDLService",
            targets: ["WSDLService"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WSDLService",
            dependencies: ["XMLCoder"]
        )
    ]
)
