// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Perfect",
    products: [
        .library(name: "PerfectLib", targets: ["PerfectLib"]),
        .library(name: "PerfectNet", targets: ["PerfectNet"]),
        .library(name: "PerfectThread", targets: ["PerfectThread"]),
        .library(name: "PerfectHTTP", targets: ["PerfectHTTP"]),
        .library(name: "PerfectHTTPServer", targets: ["PerfectHTTPServer"])
    ],
    dependencies: [ ],
    targets: [
        .target(name: "PerfectCHTTPParser"),
        .target(name: "PerfectLib"),
        .target(name: "PerfectThread"),
        .target(name: "PerfectNet", dependencies: ["PerfectThread"]),
        .target(name: "PerfectHTTP", dependencies: ["PerfectLib", "PerfectNet"]),
        .target(name: "PerfectHTTPServer", dependencies: ["PerfectCHTTPParser", "PerfectNet", "PerfectHTTP"]),
        .testTarget(name: "PerfectHTTPTests", dependencies: ["PerfectHTTP"]),
        .testTarget(name: "PerfectHTTPServerTests", dependencies: ["PerfectHTTPServer"]),
        .testTarget(name: "PerfectLibTests", dependencies: ["PerfectLib"]),
        .testTarget(name: "PerfectNetTests", dependencies: ["PerfectNet"]),
        .testTarget(name: "PerfectThreadTests", dependencies: ["PerfectThread"])
    ]
)
