// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Modules",

                      // MARK: - Platforms

                      platforms: [
                        .iOS(.v14),
                      ],

                      // MARK: - Products

                      products: [
                        // Products define the executables and libraries a package produces, and make them visible to other packages.
                        .library(name: "Modules",
                                 targets: [
                                    "Modules",
                                 ]),
                      ],

                      // MARK: - Dependencies

                      dependencies: [
                        .package(name: "UIComponents",
                                 url: "https://github.com/Somnify/UIComponents",
                                 .exact("1.2.0")),
                        .package(name: "XUI",
                                 url: "https://github.com/quickbirdstudios/XUI.git",
                                 .branch("main")),
                      ],

                      // MARK: - Targets

                      targets: [
                        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                        // Targets can depend on other targets in this package, and on products in packages this package depends on.
                        .target(name: "Modules",
                                dependencies: [
                                    .product(name: "UIComponents", package: "UIComponents"),
                                    .product(name: "XUI", package: "XUI"),
                                ]),
                      ])
