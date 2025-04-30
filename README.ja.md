# GenerateDTO

GenerateDTOは、SwiftのMacro機能を活用した自動DTOジェネレーターです。クラスに`@GenerateDTO`アノテーションを付与するだけで、対応するData Transfer Object (DTO)を自動生成します。

## 特徴

- クラスから対応するDTO構造体を自動生成
- モデルクラスとDTO間の相互変換メソッドを提供
- ネストされたDTOのサポート（コレクション型やオプショナル型にも対応）
- 完全に型安全な実装

## インストール方法

### Swift Package Managerを使用する場合

`Package.swift`ファイルの依存関係に追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/RyujiUeda/GenerateDTO.git", from: "1.0.0")
]
```

ターゲット依存関係に追加：

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["GenerateDTO"]
    )
]
```

## 使用方法

### 基本的な使い方

1. `import GenerateDTO`をファイルに追加します
2. DTOに変換したいクラスに`@GenerateDTO`アノテーションを付与します

```swift
import GenerateDTO

@GenerateDTO
public final class Person {
    public var id: UUID
    public var name: String
    public var age: Int
    
    public init(id: UUID = UUID(), name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}
```

これにより、次のようなコードが自動生成されます：

```swift
// 生成されるDTO構造体
public struct PersonDTO: DTO {
    public var id: UUID
    public var name: String
    public var age: Int
    
    public init(model: Person) {
        self.id = model.id
        self.name = model.name
        self.age = model.age
    }
    
    public func toModel() -> Person {
        .init(dto: self)
    }
}

// 元のクラスに追加される拡張
extension Person: DTOConvertible {
    public func toDTO() -> PersonDTO {
        .init(model: self)
    }
    
    public required init(dto: PersonDTO) {
        self.id = dto.id
        self.name = dto.name
        self.age = dto.age
    }
}
```

### ネストされたDTOの処理

他のDTOに変換可能なクラスをプロパティとして持つ場合、`nestedDTOs`パラメータを使用して指定します：

```swift
@GenerateDTO(nestedDTOs: ["Address", "Order"])
public final class Customer {
    public var id: UUID
    public var name: String
    public var address: Address?
    public var orders: [Order]
    
    // イニシャライザー...
}
```

この例では、`Address`と`Order`クラスも`@GenerateDTO`アノテーションが付与されていることを前提としています。

## 変換の例

```swift
// モデルインスタンスの作成
let person = Person(name: "山田太郎", age: 30)

// DTOへの変換
let personDTO = person.toDTO()
print(type(of: personDTO)) // PersonDTO

// DTOからモデルへの変換
let reconstructedPerson = personDTO.toModel()
print(type(of: reconstructedPerson)) // Person
```

## サポートしている型の変換

GenerateDTOは以下のパターンをサポートしています：

- 通常の型: `NestedType` → `NestedTypeDTO`
- オプショナル型: `NestedType?` → `NestedTypeDTO?`
- 配列型: `[NestedType]` → `[NestedTypeDTO]`
- オプショナル配列型: `[NestedType]?` → `[NestedTypeDTO]?`

## 注意事項

- 対象クラスには`public`または`internal`アクセスレベルが必要です
- DTO変換に使用するプロパティも同様のアクセスレベルが必要です
- マクロに指定した`nestedDTOs`も同様に`@GenerateDTO`アノテーションが付与されている必要があります

## ライセンス

MITライセンスで提供されています。詳細は[LICENSE](LICENSE)ファイルをご参照ください。

## コントリビューション

バグレポートや機能リクエストは、GitHubのIssueで受け付けています。プルリクエストも歓迎します。

## 謝辞

このプロジェクトはSwift Macrosの機能を活用しており、Swift言語チームの素晴らしい取り組みに感謝します。