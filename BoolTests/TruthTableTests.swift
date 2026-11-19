import XCTest
@testable import Bool

final class TruthTableTests: XCTestCase {
    
    // MARK: - Генерация наборов (2^n)
    
    func testTwoVariablesProduceFourRowsInLexicographicalOrder() {
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        let table = TruthTable(expression: node, expressionString: "A ∧ B", variables: ["A", "B"])
        
        XCTAssertEqual(table.rows.count, 4)
        
        // Ожидаемый порядок: (0,0), (0,1), (1,0), (1,1)
        XCTAssertEqual(table.rows[0].inputs, ["A": false, "B": false])
        XCTAssertEqual(table.rows[1].inputs, ["A": false, "B": true])
        XCTAssertEqual(table.rows[2].inputs, ["A": true, "B": false])
        XCTAssertEqual(table.rows[3].inputs, ["A": true, "B": true])
    }
    
    func testThreeVariablesProduceEightRows() {
        // (A ∨ B) ∧ C
        let node = ExpressionNode.binary(
            .and,
            .binary(.or, .variable("A"), .variable("B")),
            .variable("C")
        )
        let table = TruthTable(expression: node, expressionString: "(A ∨ B) ∧ C", variables: ["A", "B", "C"])
        
        XCTAssertEqual(table.rows.count, 8)
        
        // Первая строка: (0, 0, 0)
        XCTAssertEqual(table.rows[0].inputs, ["A": false, "B": false, "C": false])
        // Последняя строка: (1, 1, 1)
        XCTAssertEqual(table.rows[7].inputs, ["A": true, "B": true, "C": true])
        
        // Проверка монотонности двоичного кода строк
        for i in 0..<8 {
            let a = (i >> 2) & 1 == 1
            let b = (i >> 1) & 1 == 1
            let c = (i >> 0) & 1 == 1
            XCTAssertEqual(table.rows[i].inputs["A"], a)
            XCTAssertEqual(table.rows[i].inputs["B"], b)
            XCTAssertEqual(table.rows[i].inputs["C"], c)
        }
    }
    
    // MARK: - Корректность вычисления эталонных значений
    
    func testAndEvaluation() {
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        let table = TruthTable(expression: node, expressionString: "A ∧ B", variables: ["A", "B"])
        
        let expectedOutputs = table.rows.map { $0.expectedOutput }
        // 00 -> 0, 01 -> 0, 10 -> 0, 11 -> 1
        XCTAssertEqual(expectedOutputs, [false, false, false, true])
    }
    
    func testOrEvaluation() {
        let node = ExpressionNode.binary(.or, .variable("A"), .variable("B"))
        let table = TruthTable(expression: node, expressionString: "A ∨ B", variables: ["A", "B"])
        
        let expectedOutputs = table.rows.map { $0.expectedOutput }
        // 00 -> 0, 01 -> 1, 10 -> 1, 11 -> 1
        XCTAssertEqual(expectedOutputs, [false, true, true, true])
    }
    
    func testXorEvaluation() {
        let node = ExpressionNode.binary(.xor, .variable("A"), .variable("B"))
        let table = TruthTable(expression: node, expressionString: "A ⊕ B", variables: ["A", "B"])
        
        let expectedOutputs = table.rows.map { $0.expectedOutput }
        // 00 -> 0, 01 -> 1, 10 -> 1, 11 -> 0
        XCTAssertEqual(expectedOutputs, [false, true, true, false])
    }
    
    func testImpliesEvaluation() {
        let node = ExpressionNode.binary(.implies, .variable("A"), .variable("B"))
        let table = TruthTable(expression: node, expressionString: "A → B", variables: ["A", "B"])
        
        let expectedOutputs = table.rows.map { $0.expectedOutput }
        // A -> B ложно только при 1 -> 0
        // 00 -> 1, 01 -> 1, 10 -> 0, 11 -> 1
        XCTAssertEqual(expectedOutputs, [true, true, false, true])
    }
    
    // MARK: - Ответы пользователя и валидация
    
    func testUserOutputAndCorrectness() {
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        var table = TruthTable(expression: node, expressionString: "A ∧ B", variables: ["A", "B"])
        
        XCTAssertFalse(table.isFullyFilled)
        XCTAssertEqual(table.correctRowCount, 0)
        
        // Вводим все правильные ответы кроме одного: [0, 0, 1, 1] вместо [0, 0, 0, 1]
        table.setUserOutput(false, forRowAt: 0) // верно (0 == 0)
        table.setUserOutput(false, forRowAt: 1) // верно (0 == 0)
        table.setUserOutput(true, forRowAt: 2)  // ошибка! (введено 1, а ожидается 0)
        table.setUserOutput(true, forRowAt: 3)  // верно (1 == 1)
        
        XCTAssertTrue(table.isFullyFilled)
        XCTAssertEqual(table.correctRowCount, 3)
        XCTAssertEqual(table.totalRowCount, 4)
        XCTAssertEqual(table.accuracy, 0.75, accuracy: 0.001)
        XCTAssertFalse(table.isPerfect)
        
        // Исправляем ошибку
        table.setUserOutput(false, forRowAt: 2)
        XCTAssertEqual(table.correctRowCount, 4)
        XCTAssertTrue(table.isPerfect)
    }
    
    func testToggleUserOutput() {
        let node = ExpressionNode.variable("A")
        var table = TruthTable(expression: node, expressionString: "A", variables: ["A"])
        
        // Изначально nil
        XCTAssertNil(table.rows[0].userOutput)
        
        // Первый тап: nil -> false (0)
        table.toggleUserOutput(forRowAt: 0)
        XCTAssertEqual(table.rows[0].userOutput, false)
        
        // Второй тап: false -> true (1)
        table.toggleUserOutput(forRowAt: 0)
        XCTAssertEqual(table.rows[0].userOutput, true)
        
        // Третий тап: true -> false (0)
        table.toggleUserOutput(forRowAt: 0)
        XCTAssertEqual(table.rows[0].userOutput, false)
    }
    
    // MARK: - Совместимость с ResultViewController
    
    func testConversionToUserAnswers() {
        let node = ExpressionNode.binary(.or, .variable("A"), .variable("B"))
        var table = TruthTable(expression: node, expressionString: "A ∨ B", variables: ["A", "B"])
        
        table.setUserOutput(false, forRowAt: 0) // верный
        table.setUserOutput(false, forRowAt: 1) // ошибочный (ожидался true)
        
        let answers = table.toUserAnswers()
        XCTAssertEqual(answers.count, 4)
        
        // Проверяем формат первой строки
        XCTAssertEqual(answers[0].questionText, "[A=0, B=0] для F = A ∨ B")
        XCTAssertEqual(answers[0].userAnswerText, "0")
        XCTAssertEqual(answers[0].correctAnswerText, "0")
        XCTAssertTrue(answers[0].isCorrect)
        
        // Проверяем вторую ошибочную строку
        XCTAssertEqual(answers[1].questionText, "[A=0, B=1] для F = A ∨ B")
        XCTAssertEqual(answers[1].userAnswerText, "0")
        XCTAssertEqual(answers[1].correctAnswerText, "1")
        XCTAssertFalse(answers[1].isCorrect)
        
        // Незаполненная строка
        XCTAssertEqual(answers[2].userAnswerText, "—")
        XCTAssertFalse(answers[2].isCorrect)
    }
    
    // MARK: - Генерация под уровни сложности
    
    func testGenerationForDifferentDifficulties() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            for _ in 0..<10 {
                let table = TruthTable.generate(difficulty: difficulty)
                XCTAssertGreaterThanOrEqual(table.variables.count, 2)
                XCTAssertGreaterThanOrEqual(table.totalRowCount, 4)
                XCTAssertFalse(table.expressionString.isEmpty)
                
                // Проверяем, что все строки инициализированы
                for row in table.rows {
                    XCTAssertNil(row.userOutput)
                }
            }
        }
    }
    
    func testNoDuplicateExpressionsWhenExcluding() {
        var used: Set<String> = []
        for _ in 0..<3 {
            let table = TruthTable.generate(difficulty: .easy, excluding: used)
            XCTAssertFalse(used.contains(table.expressionString), "Выражение не должно повторяться в пределах сессии")
            used.insert(table.expressionString)
        }
        XCTAssertEqual(used.count, 3)
    }
    
    func testMultiTableUserAnswersAggregation() {
        // Симулируем 3 таблицы по 2 переменные (4 строки каждая) = 12 строк
        let node1 = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        var table1 = TruthTable(expression: node1, expressionString: "A ∧ B", variables: ["A", "B"])
        for i in 0..<4 {
            table1.setUserOutput(table1.rows[i].expectedOutput, forRowAt: i)
        }
        
        let node2 = ExpressionNode.binary(.or, .variable("A"), .variable("B"))
        let table2 = TruthTable(expression: node2, expressionString: "A ∨ B", variables: ["A", "B"])
        // Не решали table2
        
        let node3 = ExpressionNode.binary(.xor, .variable("A"), .variable("B"))
        let table3 = TruthTable(expression: node3, expressionString: "A ⊕ B", variables: ["A", "B"])
        // Не решали table3
        
        let allTables = [table1, table2, table3]
        let allAnswers = allTables.flatMap { $0.toUserAnswers() }
        
        XCTAssertEqual(allAnswers.count, 12, "Всего вопросов должно быть 12")
        let correctCount = allAnswers.filter { $0.isCorrect }.count
        XCTAssertEqual(correctCount, 4, "Правильно решено 4 из 12")
    }
}
