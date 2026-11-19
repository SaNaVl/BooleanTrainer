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
            operations = [.and, .or, .not, .nand, .nor, .xor, .implies, .equivalent]
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
                && attempts < 100
        
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
        if containsDoubleNegation(tree) { return true }
        if isTrivialRoot(tree) { return true }
        
        let allVars = tree.collectVariables()
        let usedVars = Set(allVars)
        
        switch difficulty {
        case .easy:
            // В легком: ровно 2 вхождения переменных, каждая ровно по 1 разу (например, ¬A → B)
            if allVars.count != 2 { return true }
            if usedVars.count != 2 { return true }
            
        case .medium:
            // В среднем: ровно 3 вхождения переменных (например, (A → B) ↔ A)
            if allVars.count != 3 { return true }
            if usedVars.count < 2 { return true }
            
        case .hard:
            // В сложном: от 4 до 5 вхождений переменных (например, ¬(A → B) ↔ (A ↑ ¬B))
            if allVars.count < 4 || allVars.count > 5 { return true }
            if usedVars.count < 2 { return true }
            if countBinaryOperations(tree) < 2 { return true }
        }
        
        return false
    }
    
    private static func containsDoubleNegation(_ node: ExpressionNode) -> Bool {
        switch node {
        case .variable, .constant:
            return false
        case .negation(let child):
            if case .negation = child { return true }
            return containsDoubleNegation(child)
        case .binary(_, let left, let right):
            return containsDoubleNegation(left) || containsDoubleNegation(right)
        }
    }

    private static func isTrivialRoot(_ node: ExpressionNode) -> Bool {
        guard case .binary(_, let left, let right) = node else { return false }
        if left.toString() == right.toString() { return true }
        if case .negation(let inner) = right,
           left.toString() == inner.toString() { return true }
        if case .negation(let inner) = left,
           right.toString() == inner.toString() { return true }
        return false
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
        
        // Веса зависят от сложности
        let vWeight = weightForVariable(difficulty: difficulty, depth: depth)
        let oWeight = weightForOperation(difficulty: difficulty, depth: depth)
        
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
            // Не оборачиваем отрицание в отрицание
            if case .negation = child {
                return child
            }
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
                                          depth: Int) -> Int {
        if depth == 1 { return 0 }
        
        switch difficulty {
        case .easy:
            return 3
        case .medium:
            return (depth == 2) ? 2 : 3
        case .hard:
            return (depth == 2) ? 1 : 4
        }
    }
    
    private static func weightForOperation(difficulty: Difficulty,
                                           depth: Int) -> Int {
        if depth == 1 { return 10 }
        
        switch difficulty {
        case .easy:
            return 1
        case .medium:
            return (depth == 2) ? 2 : 1
        case .hard:
            return (depth == 2) ? 4 : 1
        }
    }
}
