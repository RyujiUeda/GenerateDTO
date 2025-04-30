//
//  GenerateDTOTests.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/29.
//

@testable import GenerateDTO
import XCTest
import Foundation

// MARK: - テストクラス
public final class GenerateDTOTests: XCTestCase {
    
    // MARK: - 基本テスト
    public func testBasicDTO() {
        // モデルからDTOへの変換テスト
        let model = BasicModel(id: 1, name: "Test", isActive: true)
        let dto = model.toDTO()
        
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.name, "Test")
        XCTAssertEqual(dto.isActive, true)
        
        // DTOからモデルへの変換テスト
        let convertedModel = dto.toModel()
        
        XCTAssertEqual(convertedModel.id, 1)
        XCTAssertEqual(convertedModel.name, "Test")
        XCTAssertEqual(convertedModel.isActive, true)
    }
    
    // MARK: - ネストされたDTO変換テスト
    public func testNestedDTO() {
        // モデルからDTOへの変換テスト
        let address = Address(street: "123 Main St", city: "New York")
        let person = Person(name: "John", address: address)
        let personDTO = person.toDTO()
        
        XCTAssertEqual(personDTO.name, "John")
        XCTAssertEqual(personDTO.address.street, "123 Main St")
        XCTAssertEqual(personDTO.address.city, "New York")
        
        // DTOからモデルへの変換テスト
        let convertedPerson = personDTO.toModel()
        
        XCTAssertEqual(convertedPerson.name, "John")
        XCTAssertEqual(convertedPerson.address.street, "123 Main St")
        XCTAssertEqual(convertedPerson.address.city, "New York")
    }
    
    // MARK: - 配列とオプショナル型のテスト
    public func testArraysAndOptionals() {
        // テストデータ
        let item1 = ProductItem(id: 1, name: "Item 1")
        let item2 = ProductItem(id: 2, name: "Item 2")
        let item3 = ProductItem(id: 3, name: "Item 3")
        
        let container = Container(
            items: [item1, item2],
            optionalItem: item3,
            optionalItems: [item1, item3],
            regularValue: "Regular"
        )
        
        // モデルからDTOへの変換テスト
        let containerDTO = container.toDTO()
        
        // 配列のテスト
        XCTAssertEqual(containerDTO.items.count, 2)
        XCTAssertEqual(containerDTO.items[0].id, 1)
        XCTAssertEqual(containerDTO.items[1].name, "Item 2")
        
        // オプショナルのテスト
        XCTAssertNotNil(containerDTO.optionalItem)
        XCTAssertEqual(containerDTO.optionalItem?.id, 3)
        
        // オプショナル配列のテスト
        XCTAssertNotNil(containerDTO.optionalItems)
        XCTAssertEqual(containerDTO.optionalItems?.count, 2)
        XCTAssertEqual(containerDTO.optionalItems?[1].id, 3)
        
        // 通常値のテスト
        XCTAssertEqual(containerDTO.regularValue, "Regular")
        
        // DTOからモデルへの変換テスト
        let convertedContainer = containerDTO.toModel()
        
        // 配列のテスト
        XCTAssertEqual(convertedContainer.items.count, 2)
        XCTAssertEqual(convertedContainer.items[0].id, 1)
        XCTAssertEqual(convertedContainer.items[1].name, "Item 2")
        
        // オプショナルのテスト
        XCTAssertNotNil(convertedContainer.optionalItem)
        XCTAssertEqual(convertedContainer.optionalItem?.id, 3)
        
        // オプショナル配列のテスト
        XCTAssertNotNil(convertedContainer.optionalItems)
        XCTAssertEqual(convertedContainer.optionalItems?.count, 2)
        XCTAssertEqual(convertedContainer.optionalItems?[1].id, 3)
        
        // 通常値のテスト
        XCTAssertEqual(convertedContainer.regularValue, "Regular")
    }
    
    // MARK: - 複雑なネストのテスト
    public func testComplexNesting() {
        // テストデータ
        let department = Department(id: 1, name: "Engineering")
        let employee1 = Employee(id: 101, name: "Alice", department: department)
        let employee2 = Employee(id: 102, name: "Bob", department: department)
        let company = Company(name: "Tech Corp", employees: [employee1, employee2])
        
        // モデルからDTOへの変換テスト
        let companyDTO = company.toDTO()
        
        XCTAssertEqual(companyDTO.name, "Tech Corp")
        XCTAssertEqual(companyDTO.employees.count, 2)
        XCTAssertEqual(companyDTO.employees[0].name, "Alice")
        XCTAssertEqual(companyDTO.employees[0].department.name, "Engineering")
        XCTAssertEqual(companyDTO.employees[1].id, 102)
        
        // DTOからモデルへの変換テスト
        let convertedCompany = companyDTO.toModel()
        
        XCTAssertEqual(convertedCompany.name, "Tech Corp")
        XCTAssertEqual(convertedCompany.employees.count, 2)
        XCTAssertEqual(convertedCompany.employees[0].name, "Alice")
        XCTAssertEqual(convertedCompany.employees[0].department.name, "Engineering")
        XCTAssertEqual(convertedCompany.employees[1].id, 102)
    }
    
    // MARK: - エッジケースのテスト
    public func testEmptyCollections() {
        // 空の配列とnilオプショナルのテスト
        let emptyContainer = EmptyContainer(items: [], optionalItems: nil)
        let dto = emptyContainer.toDTO()
        
        XCTAssertEqual(dto.items.count, 0)
        XCTAssertNil(dto.optionalItems)
        
        // DTOからモデルへの変換テスト
        let convertedContainer = dto.toModel()
        
        XCTAssertEqual(convertedContainer.items.count, 0)
        XCTAssertNil(convertedContainer.optionalItems)
    }
    
    // MARK: - アノテーションパラメータのテスト
    public func testAnnotationParameters() {
        // 空のnestedDTOsパラメータのテスト
        let emptyModel = EmptyNestedModel(id: 123)
        let emptyDTO = emptyModel.toDTO()
        
        XCTAssertEqual(emptyDTO.id, 123)
        
        // 複数のnestedDTOsパラメータのテスト
        let typeA = TypeA(name: "Test A")
        let typeB = TypeB(value: 42)
        let model = MultipleNestedModel(
            a: typeA,
            b: typeB,
            arrayOfA: [typeA, TypeA(name: "Another A")],
            optionalB: typeB
        )
        
        // モデルからDTOへの変換テスト
        let dto = model.toDTO()
        
        XCTAssertEqual(dto.a.name, "Test A")
        XCTAssertEqual(dto.b.value, 42)
        XCTAssertEqual(dto.arrayOfA.count, 2)
        XCTAssertEqual(dto.arrayOfA[1].name, "Another A")
        XCTAssertEqual(dto.optionalB?.value, 42)
        
        // DTOからモデルへの変換テスト
        let convertedModel = dto.toModel()
        
        XCTAssertEqual(convertedModel.a.name, "Test A")
        XCTAssertEqual(convertedModel.b.value, 42)
        XCTAssertEqual(convertedModel.arrayOfA.count, 2)
        XCTAssertEqual(convertedModel.arrayOfA[1].name, "Another A")
        XCTAssertEqual(convertedModel.optionalB?.value, 42)
    }
    
    // MARK: - パラメータ初期化のテスト
    public func testParameterInitialization() {
        // DTOの直接初期化テスト
        let dto = BasicModelDTO(id: 42, name: "Direct Init", isActive: false)
        
        XCTAssertEqual(dto.id, 42)
        XCTAssertEqual(dto.name, "Direct Init")
        XCTAssertEqual(dto.isActive, false)
        
        // DTOからモデルへの変換テスト
        let model = dto.toModel()
        
        XCTAssertEqual(model.id, 42)
        XCTAssertEqual(model.name, "Direct Init")
        XCTAssertEqual(model.isActive, false)
    }

    // MARK: - ネストされたDTOのパラメータ初期化テスト
    public func testNestedParameterInitialization() {
        // ネストされたDTOの初期化
        let addressDTO = AddressDTO(street: "456 Park Ave", city: "Boston")
        
        // メインDTOの初期化
        let personDTO = PersonDTO(name: "Jane", address: addressDTO)
        
        XCTAssertEqual(personDTO.name, "Jane")
        XCTAssertEqual(personDTO.address.street, "456 Park Ave")
        XCTAssertEqual(personDTO.address.city, "Boston")
        
        // DTOからモデルへの変換テスト
        let convertedPerson = personDTO.toModel()
        
        XCTAssertEqual(convertedPerson.name, "Jane")
        XCTAssertEqual(convertedPerson.address.street, "456 Park Ave")
        XCTAssertEqual(convertedPerson.address.city, "Boston")
    }

    // MARK: - 配列とオプショナル型のパラメータ初期化テスト
    public func testComplexParameterInitialization() {
        // 基本DTOの初期化
        let item1DTO = ProductItemDTO(id: 10, name: "Item X")
        let item2DTO = ProductItemDTO(id: 20, name: "Item Y")
        
        // 複雑なDTOの初期化
        let containerDTO = ContainerDTO(
            items: [item1DTO, item2DTO],
            optionalItem: item1DTO,
            optionalItems: [item2DTO],
            regularValue: "Test Value"
        )
        
        // アサーション
        XCTAssertEqual(containerDTO.items.count, 2)
        XCTAssertEqual(containerDTO.items[0].id, 10)
        XCTAssertEqual(containerDTO.items[1].name, "Item Y")
        XCTAssertEqual(containerDTO.optionalItem?.id, 10)
        XCTAssertEqual(containerDTO.optionalItems?.count, 1)
        XCTAssertEqual(containerDTO.optionalItems?[0].name, "Item Y")
        XCTAssertEqual(containerDTO.regularValue, "Test Value")
        
        // DTOからモデルへの変換テスト
        let convertedContainer = containerDTO.toModel()
        
        XCTAssertEqual(convertedContainer.items.count, 2)
        XCTAssertEqual(convertedContainer.items[0].id, 10)
        XCTAssertEqual(convertedContainer.optionalItem?.id, 10)
        XCTAssertEqual(convertedContainer.regularValue, "Test Value")
    }

    // MARK: - ミックスパターンのテスト（モデル→DTO→パラメータ→DTO→モデル）
    public func testMixedInitializationPatterns() {
        // 1. 最初のモデルを作成
        let originalModel = BasicModel(id: 100, name: "Original", isActive: true)
        
        // 2. モデルからDTOへ変換
        let firstDTO = originalModel.toDTO()
        
        // 3. DTOのプロパティを使って新しいDTOを初期化
        let secondDTO = BasicModelDTO(
            id: firstDTO.id,
            name: firstDTO.name + " Modified",
            isActive: !firstDTO.isActive
        )
        
        // 4. 新しいDTOをモデルに変換
        let finalModel = secondDTO.toModel()
        
        // アサーション
        XCTAssertEqual(finalModel.id, 100)
        XCTAssertEqual(finalModel.name, "Original Modified")
        XCTAssertEqual(finalModel.isActive, false)
    }
}
