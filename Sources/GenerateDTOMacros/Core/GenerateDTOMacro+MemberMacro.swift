//
//  GenerateDTOMacro+MemberMacro.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//

import SwiftSyntax
import SwiftSyntaxMacros

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
