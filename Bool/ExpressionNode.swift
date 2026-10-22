import Foundation

/// Узел дерева логического выражения
indirect enum ExpressionNode {
    case variable(Character)
    case constant(Bool)
    case negation(ExpressionNode)
    case binary(LogicOperation, ExpressionNode, ExpressionNode)
}

extension ExpressionNode {
    
    /// Рекурсивное вычисление значения выражения
    func evaluate(with values: [Character: Bool]) -> Bool {
        switch self {
        case .variable(let name):
            return values[name] ?? false
        case .constant(let value):
            return value
        case .negation(let child):
            return !child.evaluate(with: values)
        case .binary(let op, let left, let right):
            return op.evaluate(left.evaluate(with: values),
                               right.evaluate(with: values))
        }
    }
    
    /// Рекурсивная печать в строку с расстановкой скобок по приоритетам
    func toString(parentPrecedence: Int = -1) -> String {
        switch self {
        case .variable(let name):
            return String(name)
        case .constant(let value):
            return value ? "1" : "0"
        case .negation(let child):
            let inner = child.toString(parentPrecedence: LogicOperation.not.precedence)
            return "¬\(inner)"
        case .binary(let op, let left, let right):
            let myPrecedence = op.precedence
            let leftStr = left.toString(parentPrecedence: myPrecedence)
            let rightStr = right.toString(parentPrecedence: myPrecedence)
            let result = "\(leftStr) \(op.rawValue) \(rightStr)"
            // Если приоритет ниже, чем у родителя — оборачиваем в скобки
            if myPrecedence < parentPrecedence {
                return "(\(result))"
            }
            return result
        }
    }
    
    /// Собирает все переменные, встречающиеся в дереве
    func collectVariables() -> [Character] {
        switch self {
        case .variable(let name):
            return [name]
        case .constant:
            return []
        case .negation(let child):
            return child.collectVariables()
        case .binary(_, let left, let right):
            return left.collectVariables() + right.collectVariables()
        }
    }
}
