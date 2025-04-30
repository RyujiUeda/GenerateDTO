//
//  PropertyInfo.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//

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
