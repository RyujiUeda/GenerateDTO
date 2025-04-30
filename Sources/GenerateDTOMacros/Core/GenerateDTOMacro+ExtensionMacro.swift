//
//  GenerateDTOMacro+ExtensionMacro.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//

import SwiftSyntax
import SwiftSyntaxMacros

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
