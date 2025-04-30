// swift-tools-version: 6.0.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "GenerateDTO",
    platforms: [.macOS(.v12), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(
            name: "GenerateDTO",
            targets: ["GenerateDTO"]
        ),
        .executable(
            name: "GenerateDTOClient",
            targets: ["GenerateDTOClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        // マクロの実装
        .macro(
            name: "GenerateDTOMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        // マクロライブラリ
        .target(
            name: "GenerateDTO",
            dependencies: ["GenerateDTOMacros"]
        ),
        .testTarget(
            name: "GenerateDTOTests",
            dependencies: ["GenerateDTO"]
        ),
        
        // サンプルクライアント
        .executableTarget(
            name: "GenerateDTOClient",
            dependencies: ["GenerateDTO"]
        ),
    ]
)
