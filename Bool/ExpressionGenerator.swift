import Foundation

class ExpressionGenerator {
    
    struct GeneratedExpression {
        let tree: ExpressionNode
        let expression: String
        let variables: [Character]
        let truthValues: [Character: Bool]
        let result: Bool
    }
    
    // MARK: - Public API
    
    static func generateExpression(difficulty: Difficulty) -> GeneratedExpression {
        let variableCount: Int
        let maxDepth: Int
        let allowParentheses: Bool
        let operations: [LogicOperation]
        
        switch difficulty {
        case .easy:
            variableCount = 2
            maxDepth = 2
            allowParentheses = false
            operations = [.and, .or, .not]
        case .medium:
            variableCount = 2
            maxDepth = 3
            allowParentheses = true
            operations = [.and, .or, .not, .nand, .nor, .xor, .implies, .equivalent]
        case .hard:
            variableCount = 3
            maxDepth = 4
            allowParentheses = true
            operations = [.and, .or, .not, .nand, .nor, .xor, .implies, .equivalent]
        }
        
        // Готовим переменные и их значения
        let letters: [Character] = ["A", "B", "C"]
        let variables = Array(letters.prefix(variableCount))
        var truthValues: [Character: Bool] = [:]
        for v in variables {
            truthValues[v] = Bool.random()
        }
        
        // Генерируем дерево с отсевом тривиальных вариантов
        var tree: ExpressionNode
        var attempts = 0
        repeat {
            tree = generateNode(
                depth: 1,
                maxDepth: maxDepth,
                variables: variables,
                operations: operations,
                difficulty: difficulty,
                allowParentheses: allowParentheses
            )
            attempts += 1
        } while shouldRegenerate(tree: tree, difficulty: difficulty)
                && attempts < 30
        
        let expression = tree.toString()
        let result = tree.evaluate(with: truthValues)
        
        // Оставляем только переменные, реально встречающиеся в дереве
        let usedVariables = Array(Set(tree.collectVariables())).sorted()
        
        return GeneratedExpression(
            tree: tree,
            expression: expression,
            variables: usedVariables,
            truthValues: truthValues,
            result: result
        )
    }
    
    // MARK: - Проверка, надо ли перегенерировать
    
    private static func shouldRegenerate(tree: ExpressionNode,
                                         difficulty: Difficulty) -> Bool {
        // Тривиальное выражение — всегда плохо
        if isTrivial(tree) { return true }
        
        let usedVars = Set(tree.collectVariables())
        
        // На hard нужно минимум 2 разные переменные
        if difficulty == .hard && usedVars.count < 2 { return true }
        
        // На medium тоже — хотя бы 2
        if difficulty == .medium && usedVars.count < 2 { return true }
        
        // На hard — минимум 2 бинарные операции в дереве
        if difficulty == .hard && countBinaryOperations(tree) < 2 { return true }
        
        return false
    }
    
    private static func isTrivial(_ node: ExpressionNode) -> Bool {
        switch node {
        case .variable, .constant:
            return true
        case .negation(let child):
            if case .negation = child { return true } // ¬¬X
            return isTrivial(child)
        case .binary(_, let left, let right):
            // A ∧ A, A ∨ A — одинаковые операнды
            if left.toString() == right.toString() { return true }
            // A op ¬A
            if case .negation(let inner) = right,
               left.toString() == inner.toString() { return true }
            if case .negation(let inner) = left,
               right.toString() == inner.toString() { return true }
            return false
        }
    }
    
    private static func countBinaryOperations(_ node: ExpressionNode) -> Int {
        switch node {
        case .variable, .constant:
            return 0
        case .negation(let child):
            return countBinaryOperations(child)
        case .binary(_, let left, let right):
            return 1 + countBinaryOperations(left) + countBinaryOperations(right)
        }
    }
    
    // MARK: - Рекурсивная генерация с весами
    
    private static func generateNode(
        depth: Int,
        maxDepth: Int,
        variables: [Character],
        operations: [LogicOperation],
        difficulty: Difficulty,
        allowParentheses: Bool
    ) -> ExpressionNode {
        
        // Лист — только переменная
        if depth >= maxDepth {
            let v = variables.randomElement() ?? "A"
            return .variable(v)
        }
        
        let isRoot = (depth == 1)
        
        // Веса зависят от сложности
        let vWeight = weightForVariable(difficulty: difficulty, isRoot: isRoot)
        let oWeight = weightForOperation(difficulty: difficulty, isRoot: isRoot)
        
        // Собираем пул выборов: 0 — переменная, 1 — отрицание, 2 — бинарная операция
        var choices: [Int] = []
        for _ in 0..<vWeight { choices.append(0) }
        choices.append(1) // отрицание всегда 1 раз
        for _ in 0..<oWeight { choices.append(2) }
        
        let choice = choices.randomElement() ?? 2
        
        switch choice {
        case 0:
            let v = variables.randomElement() ?? "A"
            return .variable(v)
            
        case 1:
            let child = generateNode(
                depth: depth + 1,
                maxDepth: maxDepth,
                variables: variables,
                operations: operations,
                difficulty: difficulty,
                allowParentheses: allowParentheses
            )
            return .negation(child)
            
        default:
            let binaryOps = operations.filter { $0.operandCount == 2 }
            let op = binaryOps.randomElement() ?? .and
            
            let left = generateNode(
                depth: depth + 1,
                maxDepth: maxDepth,
                variables: variables,
                operations: operations,
                difficulty: difficulty,
                allowParentheses: allowParentheses
            )
            let right = generateNode(
                depth: depth + 1,
                maxDepth: maxDepth,
                variables: variables,
                operations: operations,
                difficulty: difficulty,
                allowParentheses: allowParentheses
            )
            return .binary(op, left, right)
        }
    }
    
    // MARK: - Веса для разных уровней сложности
    
    private static func weightForVariable(difficulty: Difficulty,
                                          isRoot: Bool) -> Int {
        // На корне переменная запрещена — возвращаем 0
        if isRoot { return 0 }
        
        switch difficulty {
        case .easy:   return 3
        case .medium: return 2
        case .hard:   return 1  // редко листья, больше структуры
        }
    }
    
    private static func weightForOperation(difficulty: Difficulty,
                                           isRoot: Bool) -> Int {
        // На корне всегда операция, даём ей повышенный вес
        if isRoot { return 10 }
        
        switch difficulty {
        case .easy:   return 1
        case .medium: return 2
        case .hard:   return 4  // на hard чаще операции
        }
    }
}
