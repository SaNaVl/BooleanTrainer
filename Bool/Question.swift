import Foundation


enum Difficulty: Int {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var description: String {
        switch self {
        case .easy: return "Легкий"
        case .medium: return "Средний"
        case .hard: return "Сложный"
        }
    }
}

// Типы вопросов
enum QuestionType {
    case compute      // Вычислить значение
    case statement    // Верно/неверно утверждение
}

// Структура вопроса
struct Question {
    let type: QuestionType
    let difficulty: Difficulty
    let text: String
    let options: [String]        // Варианты ответов
    let correctAnswerIndex: Int  // Индекс правильного ответа
    
    // Для отладки - красивое описание
    var description: String {
        return "[\(difficulty.description)] \(text)\nВарианты: \(options.joined(separator: ", "))"
    }
}
