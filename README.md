# GenerateDTO

GenerateDTO is an automatic DTO generator utilizing Swift's Macro functionality. By simply adding the `@GenerateDTO` annotation to your classes, corresponding Data Transfer Objects (DTOs) are automatically generated.

## Features

- Automatically generates DTO structures from model classes
- Provides bidirectional conversion methods between models and DTOs
- Supports nested DTOs (including collections and optional types)
- Implements a fully type-safe approach

## Installation

### Using Swift Package Manager

Add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/RyujiUeda/GenerateDTO.git", from: "1.0.0")
]
```

Add it to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["GenerateDTO"]
    )
]
```

## Usage

### Basic Usage

1. Add `import GenerateDTO` to your file
2. Add the `@GenerateDTO` annotation to any class you want to convert to a DTO

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

This will automatically generate code like:

```swift
// Generated DTO structure
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

// Extension added to original class
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

### Handling Nested DTOs

When you have properties that are also DTO-convertible classes, specify them using the `nestedDTOs` parameter:

```swift
@GenerateDTO(nestedDTOs: ["Address", "Order"])
public final class Customer {
    public var id: UUID
    public var name: String
    public var address: Address?
    public var orders: [Order]
    
    // initializer...
}
```

In this example, `Address` and `Order` classes should also be annotated with `@GenerateDTO`.

## Conversion Examples

```swift
// Create a model instance
let person = Person(name: "John Doe", age: 30)

// Convert to DTO
let personDTO = person.toDTO()
print(type(of: personDTO)) // PersonDTO

// Convert back to model
let reconstructedPerson = personDTO.toModel()
print(type(of: reconstructedPerson)) // Person
```

## Supported Type Conversions

GenerateDTO supports the following patterns:

- Regular types: `NestedType` → `NestedTypeDTO`
- Optional types: `NestedType?` → `NestedTypeDTO?`
- Array types: `[NestedType]` → `[NestedTypeDTO]`
- Optional array types: `[NestedType]?` → `[NestedTypeDTO]?`

## Requirements

- Target classes must have `public` or `internal` access level
- Properties used for DTO conversion must have appropriate access levels
- Classes specified in `nestedDTOs` must also be annotated with `@GenerateDTO`

## License

This project is available under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Bug reports and feature requests are welcome through GitHub Issues. Pull requests are also appreciated.

## Acknowledgements

This project leverages Swift Macros functionality and acknowledges the excellent work of the Swift language team.