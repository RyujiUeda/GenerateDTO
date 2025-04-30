import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

// MARK: - マクロエラー定義
enum MacroError: Error, CustomStringConvertible {
    case notClass
    case invalidNestedDTOsFormat
    
    var description: String {
        switch self {
        case .notClass:
            return "@GenerateDTO can only be applied to a class"
        case .invalidNestedDTOsFormat:
            return "nestedDTOs parameter must be an array of string literals"
        }
    }
}

// MARK: - ヘルパー型定義
struct PropertyInfo {
    let name: String
    let originalType: String
    let dtoType: String
    let isDTOConvertible: Bool
    
    func initializationCode(fromModelToDTO: Bool) -> String {
        if !isDTOConvertible {
            return "self.\(name) = \(fromModelToDTO ? "model" : "dto").\(name)"
        }
        
        let baseAssignment = "self.\(name) = \(fromModelToDTO ? "model" : "dto").\(name)"
        let conversion = fromModelToDTO ? "toDTO()" : "toModel()"
        
        // 配列型の処理
        if originalType.hasPrefix("[") && originalType.hasSuffix("]") {
            return "\(baseAssignment).map { $0.\(conversion) }"
        }
        // オプショナル配列型の処理
        else if originalType.hasPrefix("[") && originalType.hasSuffix("]?") {
            return "\(baseAssignment)?.map { $0.\(conversion) }"
        }
        // オプショナル型の処理
        else if originalType.hasSuffix("?") {
            return "\(baseAssignment)?.\(conversion)"
        }
        // 通常型の処理
        else {
            return "\(baseAssignment).\(conversion)"
        }
    }
}

// MARK: - DTO生成マクロ実装
public struct GenerateDTOMacro {}

// MARK: - 共通ヘルパーメソッド
extension GenerateDTOMacro {
    // クラス宣言の取得と検証
    static func getClassDeclaration(from declaration: some DeclSyntaxProtocol) throws -> ClassDeclSyntax {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.notClass
        }
        return classDecl
    }
    
    // nestedDTOs属性パラメータの取得
    static func extractNestedDTOs(from node: AttributeSyntax) throws -> [String] {
        var nestedDTOs: [String] = []
        
        if let attrArgs = node.arguments?.as(LabeledExprListSyntax.self) {
            for arg in attrArgs where arg.label?.text == "nestedDTOs" {
                guard let arrayExpr = arg.expression.as(ArrayExprSyntax.self) else {
                    throw MacroError.invalidNestedDTOsFormat
                }
                
                for element in arrayExpr.elements {
                    guard let stringLiteral = element.expression.as(StringLiteralExprSyntax.self) else {
                        throw MacroError.invalidNestedDTOsFormat
                    }
                    
                    let value = stringLiteral.segments.description
                        .replacingOccurrences(of: "\"", with: "")
                    nestedDTOs.append(value)
                }
            }
        }
        
        return nestedDTOs
    }
    
    // プロパティ情報の収集
    static func collectProperties(from classDecl: ClassDeclSyntax, nestedDTOs: [String]) -> [PropertyInfo] {
        var properties: [PropertyInfo] = []
        
        for member in classDecl.memberBlock.members {
            guard
                let varDecl = member.decl.as(VariableDeclSyntax.self),
                let binding = varDecl.bindings.first,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                let type = binding.typeAnnotation?.type
            else { continue }
            
            let propertyName = identifier.identifier.text
            let originalType = type.description
            
            // DTOに変換すべきかの判定
            var isDTOConvertible = false
            var dtoType = originalType
            
            for nestedType in nestedDTOs {
                // 配列型 [Type]
                if originalType == "[\(nestedType)]" {
                    dtoType = "[\(nestedType)DTO]"
                    isDTOConvertible = true
                }
                // オプショナル配列型 [Type]?
                else if originalType == "[\(nestedType)]?" {
                    dtoType = "[\(nestedType)DTO]?"
                    isDTOConvertible = true
                }
                // 通常型
                else if originalType == nestedType {
                    dtoType = "\(nestedType)DTO"
                    isDTOConvertible = true
                }
                // オプショナル型
                else if originalType == "\(nestedType)?" {
                    dtoType = "\(nestedType)DTO?"
                    isDTOConvertible = true
                }
            }
            
            properties.append(PropertyInfo(
                name: propertyName,
                originalType: originalType,
                dtoType: dtoType,
                isDTOConvertible: isDTOConvertible
            ))
        }
        
        return properties
    }
}

// MARK: - PeerMacro実装
extension GenerateDTOMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let classDecl = try getClassDeclaration(from: declaration)
        let className = classDecl.name.text
        let dtoName = "\(className)DTO"
        
        let nestedDTOs = try extractNestedDTOs(from: node)
        let properties = collectProperties(from: classDecl, nestedDTOs: nestedDTOs)
        
        // DTO構造体の生成
        let propertiesDecl = properties.map {
            "public var \($0.name): \($0.dtoType)"
        }.joined(separator: "\n")
        
        let initDTOPropertiesDecl = properties.map {
            $0.initializationCode(fromModelToDTO: true)
        }.joined(separator: "\n")
        
        let dtoDecl = """
        public struct \(dtoName): DTO {
            \(propertiesDecl)
            
            public init(model: \(className)) {
                \(initDTOPropertiesDecl)
            }
            
            public func toModel() -> \(className) {
                .init(dto: self)
            }
        }
        """
        
        return [.init(stringLiteral: dtoDecl)]
    }
}

// MARK: - ExtensionMacro実装
extension GenerateDTOMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let extensionDecl = try ExtensionDeclSyntax("""
        extension \(type): DTOConvertible {        
            public func toDTO() -> \(type)DTO {
                .init(model: self)
            }
        }
        """)
        
        return [extensionDecl]
    }
}

// MARK: - MemberMacro実装
extension GenerateDTOMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let classDecl = try getClassDeclaration(from: declaration)
        let className = classDecl.name.text
        let dtoName = "\(className)DTO"
        
        let nestedDTOs = try extractNestedDTOs(from: node)
        let properties = collectProperties(from: classDecl, nestedDTOs: nestedDTOs)
        
        let initModelPropertiesDecl = properties.map {
            $0.initializationCode(fromModelToDTO: false)
        }.joined(separator: "\n")
        
        let initDTODecl = """
        public required init(dto: \(dtoName)) {
            \(initModelPropertiesDecl)
        }
        """
        
        return [.init(stringLiteral: initDTODecl)]
    }
}

// MARK: - コンパイラプラグイン登録
@main
struct GenerateDTOPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateDTOMacro.self
    ]
}
