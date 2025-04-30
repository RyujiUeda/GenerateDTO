//
//  GenerateDTOMacro+PeerMacro.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//

import SwiftSyntax
import SwiftSyntaxMacros

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
        
        let initParametersDecl = properties.map {
            "\($0.name): \($0.dtoType)"
        }.joined(separator: ",\n")
        
        let initPropertiesDecl = properties.map {
            "self.\($0.name) = \($0.name)"
        }.joined(separator: "\n")
        
        let initDTOPropertiesDecl = properties.map {
            $0.initializationCode(fromModelToDTO: true)
        }.joined(separator: "\n")
        
        let dtoDecl = """
        public struct \(dtoName): DTO {
            \(propertiesDecl)
        
            public init(
                \(initParametersDecl)
            ) {
                \(initPropertiesDecl)
            }
            
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
