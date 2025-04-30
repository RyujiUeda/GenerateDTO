import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

// MARK: - コンパイラプラグイン登録
@main
struct GenerateDTOPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateDTOMacro.self
    ]
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
