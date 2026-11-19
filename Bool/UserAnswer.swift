import Foundation

struct UserAnswer {
    let questionText: String
    let userAnswerText: String
    let correctAnswerText: String
    let isCorrect: Bool
    let explanation: String?
    
    init(questionText: String,
         userAnswerText: String,
         correctAnswerText: String,
         isCorrect: Bool,
         explanation: String? = nil) {
        self.questionText = questionText
        self.userAnswerText = userAnswerText
        self.correctAnswerText = correctAnswerText
        self.isCorrect = isCorrect
        self.explanation = explanation
    }
}
