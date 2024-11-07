//
//  Package.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 07.11.24.
//

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WSDL2Swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WSDL2Swift",
            targets: ["WSDL2Swift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.7.0"),
        .package(url: "https://github.com/Thomvis/BrightFutures.git", from: "8.2.0"),
        .package(url: "https://github.com/cezheng/Fuzi.git", from: "3.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WSDL2Swift",
            dependencies: ["AEXML", "BrightFutures", "Fuzi"]
        )
    ]
)
