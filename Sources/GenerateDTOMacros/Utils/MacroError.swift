//
//  MacroError.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//

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
