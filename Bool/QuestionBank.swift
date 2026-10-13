import Foundation

class QuestionBank {
    
    // Настройки количества вопросов
    private struct TestConfig {
        static let easyCount = 7
        static let mediumCount = 8
        static let hardCount = 9
        
        struct Easy {
            static let theoreticalCount = 3
            static let generatedCount = 4
        }
        
        struct Medium {
            static let theoreticalCount = 4
            static let generatedCount = 4
        }
        
        struct Hard {
            static let theoreticalCount = 4
            static let generatedCount = 5
        }
    }
    
    static func getQuestions(for difficulty: Difficulty) -> [Question] {
        var questions: [Question] = []
        
        switch difficulty {
        case .easy:
            questions = generateQuestions(
                theoreticalCount: TestConfig.Easy.theoreticalCount,
                generatedCount: TestConfig.Easy.generatedCount,
                difficulty: .easy
            )
        case .medium:
            questions = generateQuestions(
                theoreticalCount: TestConfig.Medium.theoreticalCount,
                generatedCount: TestConfig.Medium.generatedCount,
                difficulty: .medium
            )
        case .hard:
            questions = generateQuestions(
                theoreticalCount: TestConfig.Hard.theoreticalCount,
                generatedCount: TestConfig.Hard.generatedCount,
                difficulty: .hard
            )
        }
        
        return questions.shuffled()
    }
    
    private static func generateQuestions(theoreticalCount: Int, generatedCount: Int, difficulty: Difficulty) -> [Question] {
        var questions: [Question] = []
        
        // Добавляем теоретические вопросы
        let theoreticalQuestions = getRandomTheoreticalQuestions(count: theoreticalCount, difficulty: difficulty)
        questions.append(contentsOf: theoreticalQuestions)
        
        // Добавляем сгенерированные выражения
        for _ in 0..<generatedCount {
            if let generatedQuestion = generateExpressionQuestion(difficulty: difficulty) {
                questions.append(generatedQuestion)
            }
        }
        
        return questions
    }
    
    private static func getRandomTheoreticalQuestions(count: Int, difficulty: Difficulty) -> [Question] {
        var allTheoretical: [TheoreticalQuestion] = []
        
        switch difficulty {
        case .easy:
            allTheoretical = TheoreticalQuestionBank.getEasyQuestions()
        case .medium:
            allTheoretical = TheoreticalQuestionBank.getMediumQuestions()
        case .hard:
            allTheoretical = TheoreticalQuestionBank.getHardQuestions()
        }
        
        let shuffled = allTheoretical.shuffled()
        let selected = Array(shuffled.prefix(min(count, allTheoretical.count)))
        
        return selected.map { theoretical in
            Question(
                type: .statement,
                difficulty: difficulty,
                text: theoretical.text,
                options: theoretical.options,
                correctAnswerIndex: theoretical.correctAnswerIndex
            )
        }
    }
    
    private static func generateExpressionQuestion(difficulty: Difficulty) -> Question? {
        let gen = ExpressionGenerator.generateExpression(difficulty: difficulty)

        var questionText = "Вычислите значение выражения:\n \(gen.expression)\n\n"
        for variable in gen.variables {
            let value = gen.truthValues[variable] ?? false
            questionText += "\(variable) = \(value ? "1" : "0")\n"
        }

        return Question(
            type: .compute,
            difficulty: difficulty,
            text: questionText,
            options: ["1", "0"],
            correctAnswerIndex: gen.result ? 0 : 1
        )
    }
}
