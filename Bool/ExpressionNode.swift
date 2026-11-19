import Foundation

/// Узел дерева логического выражения
indirect enum ExpressionNode: Equatable, CustomStringConvertible {
    case variable(Character)
    case constant(Bool)
    case negation(ExpressionNode)
    case binary(LogicOperation, ExpressionNode, ExpressionNode)
    
    var description: String {
        return toString()
    }
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
    
    // MARK: - Пошаговая трассировка вычисления
    
    /// Результат вычисления с историей шагов для разбора ошибок
    struct EvaluationTrace {
        let finalResult: Bool
        let steps: [String]
        let formattedExplanation: String
    }
    
    /// Рекурсивное вычисление с подробной историей действий
    func evaluateWithTrace(with values: [Character: Bool]) -> EvaluationTrace {
        var steps: [String] = []
        var stepCounter = 1
        
        func helper(_ node: ExpressionNode) -> (value: Bool, exprStr: String) {
            switch node {
            case .variable(let name):
                let val = values[name] ?? false
                return (val, String(name))
                
            case .constant(let val):
                return (val, val ? "1" : "0")
                
            case .negation(let child):
                let childRes = helper(child)
                let res = !childRes.value
                let childValStr = childRes.value ? "1" : "0"
                let resStr = res ? "1" : "0"
                
                let stepDesc = "\(stepCounter)) \(node.toString()) = ¬\(childValStr) = \(resStr)"
                steps.append(stepDesc)
                stepCounter += 1
                return (res, resStr)
                
            case .binary(let op, let left, let right):
                let leftRes = helper(left)
                let rightRes = helper(right)
                let res = op.evaluate(leftRes.value, rightRes.value)
                let leftValStr = leftRes.value ? "1" : "0"
                let rightValStr = rightRes.value ? "1" : "0"
                let resStr = res ? "1" : "0"
                
                let stepDesc = "\(stepCounter)) \(node.toString()) = \(leftValStr) \(op.rawValue) \(rightValStr) = \(resStr)"
                steps.append(stepDesc)
                stepCounter += 1
                return (res, resStr)
            }
        }
        
        let final = helper(self)
        
        // Форматируем список входных значений
        let vars = Array(Set(self.collectVariables())).sorted()
        let valuesStr = vars.map { v in
            let val = (values[v] ?? false) ? "1" : "0"
            return "\(v)=\(val)"
        }.joined(separator: ", ")
        
        var explanation = "При \(valuesStr):\n"
        if steps.isEmpty {
            explanation += "Значение: \(final.value ? "1" : "0")"
        } else {
            explanation += steps.joined(separator: "\n")
            explanation += "\nИтог: \(final.value ? "1" : "0")"
        }
        
        return EvaluationTrace(
            finalResult: final.value,
            steps: steps,
            formattedExplanation: explanation
        )
    }
}
