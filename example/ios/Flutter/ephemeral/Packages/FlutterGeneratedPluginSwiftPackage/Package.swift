// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "awesome_notifications", path: "../.packages/awesome_notifications-0.12.1"),
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore-5.6.12"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-5.7.0"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-3.15.2"),
        .package(name: "firebase_database", path: "../.packages/firebase_database-11.3.10"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.3.14"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.2.1"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.3.2"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "awesome-notifications", package: "awesome_notifications"),
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-database", package: "firebase_database"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
