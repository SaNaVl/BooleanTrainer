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
    
    // MARK: - Тесты на количество вхождений переменных
    
    func testVariableOccurrencesPerDifficulty() {
        // Easy: ровно 2 вхождения переменных (каждая по 1 разу)
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .easy)
            let allVars = gen.tree.collectVariables()
            XCTAssertEqual(allVars.count, 2, "На easy должно быть ровно 2 вхождения: \(gen.expression)")
            XCTAssertEqual(Set(allVars).count, 2, "На easy переменные должны быть разными: \(gen.expression)")
        }
        
        // Medium: ровно 3 вхождения переменных
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .medium)
            let allVars = gen.tree.collectVariables()
            XCTAssertEqual(allVars.count, 3, "На medium должно быть ровно 3 вхождения: \(gen.expression)")
        }
        
        // Hard: от 4 до 5 вхождений переменных
        for _ in 0..<30 {
            let gen = ExpressionGenerator.generateExpression(difficulty: .hard)
            let allVars = gen.tree.collectVariables()
            XCTAssertTrue(allVars.count >= 4 && allVars.count <= 5,
                          "На hard должно быть от 4 до 5 вхождений (получено \(allVars.count)): \(gen.expression)")
        }
    }
    
    // MARK: - Пошаговая трассировка (разбор ошибок)
    
    func testEvaluateWithTraceMatchesDirectEvaluation() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<30 {
                let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)
                let trace = gen.tree.evaluateWithTrace(with: gen.truthValues)
                
                // Итоговый результат трассировки должен в точности совпадать с прямым вычислением
                XCTAssertEqual(trace.finalResult, gen.result,
                               "Результат трассировки не совпал с эталоном: \(gen.expression)")
                XCTAssertFalse(trace.steps.isEmpty, "Шаги трассировки не должны быть пустыми")
                XCTAssertFalse(trace.formattedExplanation.isEmpty)
            }
        }
    }
    
    func testDeterministicTraceSteps() {
        // (A ∧ B) ∨ ¬A при A = 0, B = 1
        let left = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        let right = ExpressionNode.negation(.variable("A"))
        let tree = ExpressionNode.binary(.or, left, right)
        
        let trace = tree.evaluateWithTrace(with: ["A": false, "B": true])
        
        // 0 ∧ 1 = 0; ¬0 = 1; 0 ∨ 1 = 1
        XCTAssertTrue(trace.finalResult)
        XCTAssertEqual(trace.steps.count, 3)
        XCTAssertTrue(trace.steps[0].contains("A ∧ B"))
        XCTAssertTrue(trace.steps[1].contains("¬A"))
        XCTAssertTrue(trace.steps[2].contains("∨"))
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
