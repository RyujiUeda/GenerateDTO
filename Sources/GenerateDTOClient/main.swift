import Foundation
import GenerateDTO

/// 顧客を表すモデル
@GenerateDTO(nestedDTOs: ["Address", "Order"])
public final class Customer {
    public var id: UUID
    public var name: String
    public var email: String
    public var registeredAt: Date
    public var address: Address?
    public var orders: [Order]
    
    public init(id: UUID = UUID(), name: String, email: String, registeredAt: Date = Date(), address: Address? = nil, orders: [Order] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.registeredAt = registeredAt
        self.address = address
        self.orders = orders
    }
}

/// 住所を表すモデル
@GenerateDTO
public final class Address {
    public var street: String
    public var city: String
    public var postalCode: String
    public var country: String
    
    public init(street: String, city: String, postalCode: String, country: String) {
        self.street = street
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
}

/// 注文を表すモデル
@GenerateDTO
public final class Order {
    public var id: UUID
    public var orderNumber: String
    public var totalAmount: Double
    public var orderedAt: Date
    
    public init(id: UUID = UUID(), orderNumber: String, totalAmount: Double, orderedAt: Date = Date()) {
        self.id = id
        self.orderNumber = orderNumber
        self.totalAmount = totalAmount
        self.orderedAt = orderedAt
    }
}

// MARK: - デモンストレーション実行

/// 生成されたDTOの機能を実証するデモ関数
func runGenerateDTODemo() {
    print("========== GenerateDTO マクロデモンストレーション ==========")
    print()
    
    // 1. 基本的なモデルからDTOへの変換
    let address = Address(
        street: "123 Main St",
        city: "Tokyo",
        postalCode: "100-0001",
        country: "Japan"
    )
    
    let order1 = Order(
        orderNumber: "ORD-001",
        totalAmount: 5400.0
    )
    
    let order2 = Order(
        orderNumber: "ORD-002",
        totalAmount: 2800.0
    )
    
    let customer = Customer(
        name: "山田太郎",
        email: "yamada@example.com",
        address: address,
        orders: [order1, order2]
    )
    
    // モデル → DTO変換
    let customerDTO = customer.toDTO()
    
    print("【元の顧客モデル】")
    printCustomerDetails(customer)
    print()
    
    print("【生成された顧客DTO】")
    printCustomerDTODetails(customerDTO)
    print()
    
    // DTO → モデル再変換
    let reconstructedCustomer = customerDTO.toModel()
    
    print("【DTOから再構築した顧客モデル】")
    printCustomerDetails(reconstructedCustomer)
    print()
    
    // 2. ネストされたDTOの検証
    print("【ネストされたDTOの検証】")
    if let addressDTO = customerDTO.address {
        print("✓ 住所が正しくAddressDTO型に変換されました: \(type(of: addressDTO))")
        print("  - 住所: \(addressDTO.city), \(addressDTO.country)")
    }
    
    if !customerDTO.orders.isEmpty {
        print("✓ 注文配列がOrderDTO型に正しく変換されました: \(type(of: customerDTO.orders[0]))")
        print("  - 最初の注文: \(customerDTO.orders[0].orderNumber), ¥\(customerDTO.orders[0].totalAmount)")
    }
    print("\n========== デモンストレーション終了 ==========")
}

// MARK: - ヘルパー関数

/// 顧客モデルの詳細を出力する
func printCustomerDetails(_ customer: Customer) {
    print("型: \(type(of: customer))")
    print("ID: \(customer.id)")
    print("名前: \(customer.name)")
    print("メール: \(customer.email)")
    print("登録日: \(customer.registeredAt)")
    if let address = customer.address {
        print("住所: \(address.street), \(address.city), \(address.postalCode), \(address.country)")
    } else {
        print("住所: なし")
    }
    print("注文数: \(customer.orders.count)件")
    if !customer.orders.isEmpty {
        print("  - 最初の注文: \(customer.orders[0].orderNumber), ¥\(customer.orders[0].totalAmount)")
    }
}

/// 顧客DTOの詳細を出力する
func printCustomerDTODetails(_ dto: CustomerDTO) {
    print("型: \(type(of: dto))")
    print("ID: \(dto.id)")
    print("名前: \(dto.name)")
    print("メール: \(dto.email)")
    print("登録日: \(dto.registeredAt)")
    if let address = dto.address {
        print("住所: \(address.street), \(address.city), \(address.postalCode), \(address.country)")
    } else {
        print("住所: なし")
    }
    print("注文数: \(dto.orders.count)件")
    if !dto.orders.isEmpty {
        print("  - 最初の注文: \(dto.orders[0].orderNumber), ¥\(dto.orders[0].totalAmount)")
    }
}

runGenerateDTODemo()
