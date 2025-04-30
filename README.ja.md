# GenerateDTO

GenerateDTOは、SwiftのMacro機能を活用した自動DTOジェネレーターです。クラスに`@GenerateDTO`アノテーションを付与するだけで、対応するData Transfer Object (DTO)を自動生成します。

## 特徴

- クラスから対応するDTO構造体を自動生成
- 生成されるDTOはSendableに準拠しているため、actor間での安全なデータ共有が可能
- モデルクラスとDTO間の相互変換メソッドを提供
- ネストされたDTOのサポート（コレクション型やオプショナル型にも対応）


## インストール方法

### Swift Package Managerを使用する場合

`Package.swift`ファイルの依存関係に追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/RyujiUeda/GenerateDTO.git", from: "0.1.0")
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

### Concurrency対応とactor間のデータ共有

GenerateDTOで生成されるDTOはすべて`Sendable`プロトコルに準拠しているため、Swift Concurrencyモデルにおけるactor boundaryを安全に越えることができます。これにより、Sendableに対応していないモデルオブジェクトでも、DTOに変換することで異なるactor間で安全にデータを共有できます。

```swift
// モデルクラス（Sendableではない）
class UserProfile {
    var name: String
    var settings: [String: Any] // Any型を含むためSendableに適合できない
    
    init(name: String, settings: [String: Any]) {
        self.name = name
        self.settings = settings
    }
}

// DTOの生成（Sendableに準拠）
@GenerateDTO
class UserProfileDTO {
    var name: String
    var settingsJSON: String // JSON文字列に変換してSendable対応
    
    init(name: String, settingsJSON: String) {
        self.name = name
        self.settingsJSON = settingsJSON
    }
}

// 使用例
actor UserManager {
    func updateProfile(dto: UserProfileDTO) async {
        // DTOを安全に受け取り、処理できる
        let profile = dto.toModel()
        // ...処理...
    }
}

// 別の場所で
let profile = UserProfile(...)
let dto = profile.toDTO() // Sendableに準拠したDTOに変換

// actorにDTOを安全に渡す
await userManager.updateProfile(dto: dto)
```

これにより、複雑なデータ構造を持つモデルでも、actor boundaryを超えて安全に値を受け渡すことが可能になります。

### パラメータ化されたイニシャライザの使用

モデルクラスのインスタンスを持たなくても、DTOを直接作成することができます：

```swift
// DTOを直接作成
let addressDTO = AddressDTO(
    street: "東京都中央区銀座1-1-1", 
    city: "東京"
)

let personDTO = PersonDTO(
    id: UUID(),
    name: "佐藤花子", 
    age: 28,
    address: addressDTO
)

// 必要に応じてモデルに変換
let person = personDTO.toModel()
```

これは特に以下のような場合に役立ちます：
- テストデータの作成
- JSONをDTOに直接デシリアライズ
- ユーザー入力からDTOを構築
- DTO互換のデータを返すAPIの操作

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