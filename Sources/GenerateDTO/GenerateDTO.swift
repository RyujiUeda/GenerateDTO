import Foundation

/// DTO生成用マクロ
/// @GenerateDTO アノテーションをクラスに付与すると、対応するDTOが自動生成されます
@attached(member, names: named(init))
@attached(peer, names: suffixed(DTO))
@attached(extension, conformances: DTOConvertible, names: named(toDTO))
public macro GenerateDTO(nestedDTOs: [String] = []) = #externalMacro(module: "GenerateDTOMacros", type: "GenerateDTOMacro")

/// DTOに変換可能なprotocol
public protocol DTOConvertible {
    associatedtype DTOType: DTO
    func toDTO() -> DTOType
    init(dto: DTOType)
}

public protocol DTO: Sendable, Equatable {
    associatedtype Model: DTOConvertible
    init(model: Model)
    func toModel() -> Model
}
