import XCTest
@testable import Bool

final class ExpressionParserTests: XCTestCase {
    
    // MARK: - Базовый парсинг переменных и унарного отрицания
    
    func testSingleVariable() throws {
        let result = try ExpressionParser.parse("A")
        XCTAssertEqual(result.expression, .variable("A"))
        XCTAssertEqual(result.variables, ["A"])
        XCTAssertEqual(result.expressionString, "A")
    }
    
    func testNegation() throws {
        let result = try ExpressionParser.parse("¬A")
        XCTAssertEqual(result.expression, .negation(.variable("A")))
        XCTAssertEqual(result.variables, ["A"])
    }
    
    func testDoubleNegation() throws {
        let result = try ExpressionParser.parse("¬¬A")
        XCTAssertEqual(result.expression, .negation(.negation(.variable("A"))))
        XCTAssertEqual(result.variables, ["A"])
    }
    
    // MARK: - Бинарные операции
    
    func testAndOperation() throws {
        let result = try ExpressionParser.parse("A ∧ B")
        XCTAssertEqual(result.expression, .binary(.and, .variable("A"), .variable("B")))
        XCTAssertEqual(result.variables, ["A", "B"])
    }
    
    func testOrOperation() throws {
        let result = try ExpressionParser.parse("A ∨ B")
        XCTAssertEqual(result.expression, .binary(.or, .variable("A"), .variable("B")))
        XCTAssertEqual(result.variables, ["A", "B"])
    }
    
    func testAllLogicOperations() throws {
        let ops: [(String, LogicOperation)] = [
            ("A ∧ B", .and),
            ("A ∨ B", .or),
            ("A ⊕ B", .xor),
            ("A → B", .implies),
            ("A ↔ B", .equivalent),
            ("A ↑ B", .nand),
            ("A ↓ B", .nor)
        ]
        
        for (input, expectedOp) in ops {
            let res = try ExpressionParser.parse(input)
            XCTAssertEqual(res.expression, .binary(expectedOp, .variable("A"), .variable("B")), "Ошибка при парсинге \(input)")
        }
    }
    
    // MARK: - Приоритет операций и скобки
    
    func testPrecedenceAndOverOr() throws {
        // A ∨ B ∧ C должно парситься как A ∨ (B ∧ C)
        let result = try ExpressionParser.parse("A ∨ B ∧ C")
        let expected = ExpressionNode.binary(
            .or,
            .variable("A"),
            .binary(.and, .variable("B"), .variable("C"))
        )
        XCTAssertEqual(result.expression, expected)
        XCTAssertEqual(result.variables, ["A", "B", "C"])
    }
    
    func testParenthesesOverridePrecedence() throws {
        // (A ∨ B) ∧ C
        let result = try ExpressionParser.parse("(A ∨ B) ∧ C")
        let expected = ExpressionNode.binary(
            .and,
            .binary(.or, .variable("A"), .variable("B")),
            .variable("C")
        )
        XCTAssertEqual(result.expression, expected)
    }
    
    func testComplexFormulaWithImplicationAndEquivalence() throws {
        // (A → B) ↔ (¬A ∨ B)
        let result = try ExpressionParser.parse("(A → B) ↔ (¬A ∨ B)")
        let expected = ExpressionNode.binary(
            .equivalent,
            .binary(.implies, .variable("A"), .variable("B")),
            .binary(.or, .negation(.variable("A")), .variable("B"))
        )
        XCTAssertEqual(result.expression, expected)
        XCTAssertEqual(result.variables, ["A", "B"])
    }
    
    func testAlternativeAsciiSymbols() throws {
        // Проверка символов !, &, |, ^, ->, <->
        let res1 = try ExpressionParser.parse("!A & B")
        XCTAssertEqual(res1.expression, .binary(.and, .negation(.variable("A")), .variable("B")))
        
        let res2 = try ExpressionParser.parse("A -> B")
        XCTAssertEqual(res2.expression, .binary(.implies, .variable("A"), .variable("B")))
        
        let res3 = try ExpressionParser.parse("A <-> B")
        XCTAssertEqual(res3.expression, .binary(.equivalent, .variable("A"), .variable("B")))
    }
    
    func testFormulaWithParenthesesAndNegation() throws {
        // Проверка формулы (A ↔ B) ∧ ¬C
        let result = try ExpressionParser.parse("(A ↔ B) ∧ ¬C")
        let expected = ExpressionNode.binary(
            .and,
            .binary(.equivalent, .variable("A"), .variable("B")),
            .negation(.variable("C"))
        )
        XCTAssertEqual(result.expression, expected)
        XCTAssertEqual(result.variables, ["A", "B", "C"])
    }
    
    // MARK: - Обработка ошибок
    
    func testEmptyFormulaThrowsError() {
        XCTAssertThrowsError(try ExpressionParser.parse("")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .emptyExpression)
        }
        XCTAssertThrowsError(try ExpressionParser.parse("   ")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .emptyExpression)
        }
    }
    
    func testUnclosedParenthesisThrowsError() {
        XCTAssertThrowsError(try ExpressionParser.parse("(A ∧ B")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .expectedClosingParenthesis)
        }
    }
    
    func testUnexpectedClosingParenthesisThrowsError() {
        XCTAssertThrowsError(try ExpressionParser.parse("A ∧ B)")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .unexpectedClosingParenthesis)
        }
    }
    
    func testMissingOperandThrowsError() {
        XCTAssertThrowsError(try ExpressionParser.parse("A ∧")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .expectedOperand(after: "∧"))
        }
    }
    
    func testConsecutiveVariablesWithoutOperatorThrowsError() {
        XCTAssertThrowsError(try ExpressionParser.parse("A B")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .missingOperator(between: "A", and: "B"))
        }
    }
    
    func testTooManyVariablesThrowsError() {
        // A, B, C, D, E (5 переменных, а разрешено максимум 4)
        XCTAssertThrowsError(try ExpressionParser.parse("A ∧ B ∧ C ∧ D ∧ E")) { error in
            XCTAssertEqual(error as? ExpressionParserError, .tooManyVariables(count: 5, max: 4))
        }
    }
}
