//
//  TestModels.swift
//  GenerateDTO
//
//  Created by 上田龍二 on 2025/04/30.
//
 
import GenerateDTO
import Foundation

// MARK: - 基本テスト用モデル
@GenerateDTO
public class BasicModel {
    public let id: Int
    public let name: String
    public let isActive: Bool
    
    public init(id: Int, name: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.isActive = isActive
    }
}

// MARK: - ネストされたDTO用モデル
@GenerateDTO
public class Address {
    public let street: String
    public let city: String
    
    public init(street: String, city: String) {
        self.street = street
        self.city = city
    }
}

@GenerateDTO(nestedDTOs: ["Address"])
public class Person {
    public let name: String
    public let address: Address
    
    public init(name: String, address: Address) {
        self.name = name
        self.address = address
    }
}

// MARK: - 配列とオプショナル型のテスト用モデル
@GenerateDTO
public class ProductItem {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

@GenerateDTO(nestedDTOs: ["ProductItem"])
public class Container {
    public let items: [ProductItem]
    public let optionalItem: ProductItem?
    public let optionalItems: [ProductItem]?
    public let regularValue: String
    
    public init(items: [ProductItem], optionalItem: ProductItem?, optionalItems: [ProductItem]?, regularValue: String) {
        self.items = items
        self.optionalItem = optionalItem
        self.optionalItems = optionalItems
        self.regularValue = regularValue
    }
}

// MARK: - 複雑なネストのテスト用モデル
@GenerateDTO
public class Department {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

@GenerateDTO(nestedDTOs: ["Department"])
public class Employee {
    public let id: Int
    public let name: String
    public let department: Department
    
    public init(id: Int, name: String, department: Department) {
        self.id = id
        self.name = name
        self.department = department
    }
}

@GenerateDTO(nestedDTOs: ["Employee"])
public class Company {
    public let name: String
    public let employees: [Employee]
    
    public init(name: String, employees: [Employee]) {
        self.name = name
        self.employees = employees
    }
}

// MARK: - エッジケースのテスト用モデル
@GenerateDTO(nestedDTOs: ["ProductItem"])
public class EmptyContainer {
    public let items: [ProductItem]
    public let optionalItems: [ProductItem]?
    
    public init(items: [ProductItem], optionalItems: [ProductItem]?) {
        self.items = items
        self.optionalItems = optionalItems
    }
}

// MARK: - アノテーションパラメータのテスト用モデル
@GenerateDTO(nestedDTOs: [])
public class EmptyNestedModel {
    public let id: Int
    
    public init(id: Int) {
        self.id = id
    }
}

@GenerateDTO
public class TypeA {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

@GenerateDTO
public class TypeB {
    public let value: Int
    
    public init(value: Int) {
        self.value = value
    }
}

@GenerateDTO(nestedDTOs: ["TypeA", "TypeB"])
public class MultipleNestedModel {
    public let a: TypeA
    public let b: TypeB
    public let arrayOfA: [TypeA]
    public let optionalB: TypeB?
    
    public init(a: TypeA, b: TypeB, arrayOfA: [TypeA], optionalB: TypeB?) {
        self.a = a
        self.b = b
        self.arrayOfA = arrayOfA
        self.optionalB = optionalB
    }
}

// MARK: - カスタムイニシャライザテスト用モデル
@GenerateDTO
public class PersonForCustomInit {
    public let name: String
    public let age: Int
    public let status: String
    
    public init(name: String, age: Int, status: String) {
        self.name = name
        self.age = age
        self.status = status
    }
}

// MARK: - パラメータ初期化詳細テスト用モデル
@GenerateDTO
public class DepartmentWithCode {
    public let id: Int
    public let name: String
    public let code: String
    
    public init(id: Int, name: String, code: String) {
        self.id = id
        self.name = name
        self.code = code
    }
}

@GenerateDTO(nestedDTOs: ["DepartmentWithCode"])
public class EmployeeWithDetails {
    public let id: Int
    public let name: String
    public let email: String
    public let department: DepartmentWithCode
    public let startDate: Date
    
    public init(id: Int, name: String, email: String, department: DepartmentWithCode, startDate: Date) {
        self.id = id
        self.name = name
        self.email = email
        self.department = department
        self.startDate = startDate
    }
}

// MARK: - オプショナルパラメータテスト用モデル
@GenerateDTO
public class Profile {
    public let bio: String
    public let imageURL: String
    
    public init(bio: String, imageURL: String) {
        self.bio = bio
        self.imageURL = imageURL
    }
}

@GenerateDTO(nestedDTOs: ["Profile"])
public class User {
    public let id: Int
    public let username: String
    public let email: String
    public let profile: Profile?
    
    public init(id: Int, username: String, email: String, profile: Profile? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.profile = profile
    }
}
