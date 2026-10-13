import Foundation

enum LogicOperation: String, CaseIterable {
    case and = "∧"
    case or = "∨"
    case not = "¬"
    case nand = "↑"
    case nor = "↓"
    case xor = "⊕"
    case implies = "→"
    case equivalent = "↔"
    
    var precedence: Int {
        switch self {
        case .not: return 3
        case .and, .nand: return 2
        case .or, .nor, .xor: return 1
        case .implies, .equivalent: return 0
        }
    }
    
    // Количество операндов: 1 для унарных, 2 для бинарных
    var operandCount: Int {
        switch self {
        case .not: return 1
        default: return 2
        }
    }
    
    func evaluate(_ left: Bool, _ right: Bool?) -> Bool {
        switch self {
        case .and: return left && (right ?? false)
        case .or: return left || (right ?? false)
        case .not: return !left
        case .nand: return !(left && (right ?? false))
        case .nor: return !(left || (right ?? false))
        case .xor: return left != (right ?? false)
        case .implies: return !left || (right ?? false)
        case .equivalent: return left == (right ?? false)
        }
    }
}
