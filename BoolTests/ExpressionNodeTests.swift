import XCTest
@testable import Bool

final class ExpressionNodeTests: XCTestCase {
    
    // MARK: - evaluate
    
    func testVariableEvaluation() {
        let node = ExpressionNode.variable("A")
        XCTAssertTrue(node.evaluate(with: ["A": true]))
        XCTAssertFalse(node.evaluate(with: ["A": false]))
    }
    
    func testConstantEvaluation() {
        XCTAssertTrue(ExpressionNode.constant(true).evaluate(with: [:]))
        XCTAssertFalse(ExpressionNode.constant(false).evaluate(with: [:]))
    }
    
    func testNegationEvaluation() {
        let node = ExpressionNode.negation(.variable("A"))
        XCTAssertFalse(node.evaluate(with: ["A": true]))
        XCTAssertTrue(node.evaluate(with: ["A": false]))
    }
    
    func testAndEvaluation() {
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        XCTAssertTrue(node.evaluate(with: ["A": true, "B": true]))
        XCTAssertFalse(node.evaluate(with: ["A": true, "B": false]))
        XCTAssertFalse(node.evaluate(with: ["A": false, "B": true]))
        XCTAssertFalse(node.evaluate(with: ["A": false, "B": false]))
    }
    
    func testOrEvaluation() {
        let node = ExpressionNode.binary(.or, .variable("A"), .variable("B"))
        XCTAssertTrue(node.evaluate(with: ["A": true, "B": false]))
        XCTAssertTrue(node.evaluate(with: ["A": false, "B": true]))
        XCTAssertFalse(node.evaluate(with: ["A": false, "B": false]))
    }
    
    func testNestedEvaluation() {
        // (A ∧ B) ∨ ¬C
        let node = ExpressionNode.binary(
            .or,
            .binary(.and, .variable("A"), .variable("B")),
            .negation(.variable("C"))
        )
        XCTAssertTrue(node.evaluate(with: ["A": true, "B": true, "C": false]))
        XCTAssertFalse(node.evaluate(with: ["A": false, "B": true, "C": true]))
    }
    
    func testMissingVariableDefaultsToFalse() {
        // Переменная не задана → false
        let node = ExpressionNode.variable("Z")
        XCTAssertFalse(node.evaluate(with: [:]))
    }
    
    // MARK: - toString
    
    func testToStringVariable() {
        XCTAssertEqual(ExpressionNode.variable("A").toString(), "A")
    }
    
    func testToStringBinaryNoParens() {
        // A ∧ B — скобки не нужны
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("B"))
        XCTAssertEqual(node.toString(), "A ∧ B")
    }
    
    func testToStringWithParensWhenNeeded() {
        // A ∧ (B ∨ C) — скобки нужны, потому что ∨ ниже ∧
        let node = ExpressionNode.binary(
            .and,
            .variable("A"),
            .binary(.or, .variable("B"), .variable("C"))
        )
        XCTAssertEqual(node.toString(), "A ∧ (B ∨ C)")
    }
    
    func testToStringNoParensWhenNotNeeded() {
        // (A ∧ B) ∨ C — скобки не нужны, ∧ выше ∨
        let node = ExpressionNode.binary(
            .or,
            .binary(.and, .variable("A"), .variable("B")),
            .variable("C")
        )
        XCTAssertEqual(node.toString(), "A ∧ B ∨ C")
    }
    
    func testToStringNegationOfBinary() {
        // ¬(A ∧ B) — скобки нужны
        let node = ExpressionNode.negation(
            .binary(.and, .variable("A"), .variable("B"))
        )
        XCTAssertEqual(node.toString(), "¬(A ∧ B)")
    }
    
    func testToStringNegationOfVariable() {
        // ¬A — без скобок
        let node = ExpressionNode.negation(.variable("A"))
        XCTAssertEqual(node.toString(), "¬A")
    }
    
    // MARK: - collectVariables
    
    func testCollectVariablesSingle() {
        XCTAssertEqual(ExpressionNode.variable("A").collectVariables(), ["A"])
    }
    
    func testCollectVariablesNested() {
        // (A ∧ B) ∨ ¬C → A, B, C
        let node = ExpressionNode.binary(
            .or,
            .binary(.and, .variable("A"), .variable("B")),
            .negation(.variable("C"))
        )
        let vars = Set(node.collectVariables())
        XCTAssertEqual(vars, ["A", "B", "C"])
    }
    
    func testCollectVariablesWithDuplicates() {
        // A ∧ A → в дереве две A, но Set сожмёт до одной
        let node = ExpressionNode.binary(.and, .variable("A"), .variable("A"))
        let vars = Set(node.collectVariables())
        XCTAssertEqual(vars, ["A"])
    }
}
