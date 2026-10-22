import XCTest
@testable import Bool

final class ExpressionGeneratorTests: XCTestCase {
    
    // MARK: - Общие проверки для всех уровней
    
    func testGeneratorProducesValidTree() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<50 {
                let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)
                // Дерево не пустое
                XCTAssertFalse(gen.expression.isEmpty)
                // Значения переменных заданы
                XCTAssertFalse(gen.truthValues.isEmpty)
                // Результат дерева совпадает с результатом вычисления
                XCTAssertEqual(gen.tree.evaluate(with: gen.truthValues), gen.result)
            }
        }
    }
    
    func testVariablesMatchTree() {
        // В gen.variables должны быть только переменные, реально встречающиеся в дереве
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<30 {
                let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)
                let treeVars = Set(gen.tree.collectVariables())
                let reportedVars = Set(gen.variables)
                XCTAssertEqual(treeVars, reportedVars,
                    "Список переменных не совпадает с деревом: \(gen.expression)")
            }
        }
    }
    
    func testParenthesesAreBalanced() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<50 {
                let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)
                var balance = 0
                for ch in gen.expression {
                    if ch == "(" { balance += 1 }
                    if ch == ")" { balance -= 1 }
                    XCTAssertGreaterThanOrEqual(balance, 0,
                        "Несбалансированные скобки: \(gen.expression)")
                }
                XCTAssertEqual(balance, 0,
                    "Несбалансированные скобки: \(gen.expression)")
            }
        }
    }
    
    // MARK: - Easy
    
    func testEasyHasAtLeastOneVariable() {
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .easy)
            XCTAssertGreaterThanOrEqual(gen.variables.count, 1,
                "Пустое выражение: \(gen.expression)")
        }
    }
    
    func testEasyNoParentheses() {
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .easy)
            XCTAssertFalse(gen.expression.contains("("),
                "На easy скобки запрещены: \(gen.expression)")
        }
    }
    
    // MARK: - Hard
    
    func testHardHasAtLeastTwoVariables() {
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .hard)
            XCTAssertGreaterThanOrEqual(gen.variables.count, 2,
                "На hard слишком мало переменных: \(gen.expression)")
        }
    }
    
    func testHardHasAtLeastTwoBinaryOperations() {
        let binarySymbols: [Character] = ["∧", "∨", "⊕", "↑", "↓", "→", "↔"]
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .hard)
            let count = gen.expression.filter { binarySymbols.contains($0) }.count
            XCTAssertGreaterThanOrEqual(count, 2,
                "На hard слишком простое выражение: \(gen.expression)")
        }
    }
    
    func testNoDoubleNegation() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<30 {
                let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)
                XCTAssertFalse(gen.expression.contains("¬¬"),
                    "Двойное отрицание: \(gen.expression)")
            }
        }
    }
    
    // MARK: - Производительность
    
    func testGenerationPerformance() {
        measure {
            for _ in 0..<100 {
                _ = ExpressionGenerator.generateExpression(difficulty: .hard)
            }
        }
    }
}
