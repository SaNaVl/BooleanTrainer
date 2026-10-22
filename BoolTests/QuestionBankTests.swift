import XCTest
@testable import Bool

final class QuestionBankTests: XCTestCase {
    
    func testEasyQuestionCount() {
        let questions = QuestionBank.getQuestions(for: .easy)
        XCTAssertEqual(questions.count, 7, "На easy должно быть 7 вопросов")
    }
    
    func testMediumQuestionCount() {
        let questions = QuestionBank.getQuestions(for: .medium)
        XCTAssertEqual(questions.count, 8, "На medium должно быть 8 вопросов")
    }
    
    func testHardQuestionCount() {
        let questions = QuestionBank.getQuestions(for: .hard)
        XCTAssertEqual(questions.count, 9, "На hard должно быть 9 вопросов")
    }
    
    func testAllQuestionsHaveValidAnswerIndex() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            let questions = QuestionBank.getQuestions(for: difficulty)
            for question in questions {
                XCTAssertFalse(question.options.isEmpty,
                    "У вопроса нет вариантов: \(question.text)")
                XCTAssertTrue(question.correctAnswerIndex >= 0 &&
                              question.correctAnswerIndex < question.options.count,
                    "Индекс правильного ответа вне диапазона: \(question.text)")
            }
        }
    }
    
    func testQuestionTextNotEmpty() {
        for difficulty in [Difficulty.easy, .medium, .hard] {
            let questions = QuestionBank.getQuestions(for: difficulty)
            for question in questions {
                XCTAssertFalse(question.text.isEmpty,
                    "Пустой текст вопроса на \(difficulty)")
            }
        }
    }
    
    func testComputeQuestionsHaveOneZeroOption() {
        // У вычислительных вопросов варианты — ["1", "0"]
        let questions = QuestionBank.getQuestions(for: .hard)
        let computeQuestions = questions.filter { $0.type == .compute }
        XCTAssertFalse(computeQuestions.isEmpty, "Нет вычислительных вопросов")
        for q in computeQuestions {
            XCTAssertEqual(Set(q.options), Set(["1", "0"]),
                "Неверные варианты у вычислительного вопроса: \(q.options)")
        }
    }
    
    func testQuestionsAreShuffled() {
        // Два вызова подряд — маловероятно, что порядок совпадёт полностью
        let first = QuestionBank.getQuestions(for: .hard).map { $0.text }
        let second = QuestionBank.getQuestions(for: .hard).map { $0.text }
        XCTAssertNotEqual(first, second,
            "Похоже, вопросы не перемешиваются")
    }
}
