import Foundation

/// Ошибки синтаксического анализа логического выражения
enum ExpressionParserError: LocalizedError, Equatable {
    case emptyExpression
    case unexpectedCharacter(Character, position: Int)
    case expectedOperand(after: String)
    case expectedClosingParenthesis
    case unexpectedClosingParenthesis
    case missingOperator(between: String, and: String)
    case noVariables
    case tooManyVariables(count: Int, max: Int)
    
    var errorDescription: String? {
        switch self {
        case .emptyExpression:
            return "Выражение не введено. Наберите формулу с помощью кнопок."
        case .unexpectedCharacter(let char, _):
            return "Неизвестный символ: '\(char)'."
        case .expectedOperand(let after):
            return "Ожидалась переменная или скобка после '\(after)'."
        case .expectedClosingParenthesis:
            return "Не закрыта круглая скобка ')'."
        case .unexpectedClosingParenthesis:
            return "Лишняя закрывающая скобка ')'."
        case .missingOperator(let left, let right):
            return "Пропущен знак операции между '\(left)' и '\(right)'."
        case .noVariables:
            return "Формула должна содержать хотя бы одну переменную (A, B, C или D)."
        case .tooManyVariables(let count, let max):
            return "Слишком много переменных: \(count). Максимум разрешено \(max) (A, B, C, D)."
        }
    }
}

/// Результат синтаксического анализа выражения
struct ParsedFormula: Equatable {
    let expression: ExpressionNode
    let expressionString: String
    let variables: [Character]
}

/// Парсер логических выражений методом рекурсивного спуска
class ExpressionParser {
    
    public static let maxVariablesCount = 4
    
    // MARK: - Токены
    private enum Token: Equatable {
        case variable(Character)
        case not
        case and
        case or
        case xor
        case implies
        case equivalent
        case nand
        case nor
        case openParen
        case closeParen
        
        var description: String {
            switch self {
            case .variable(let c): return String(c)
            case .not: return "¬"
            case .and: return "∧"
            case .or: return "∨"
            case .xor: return "⊕"
            case .implies: return "→"
            case .equivalent: return "↔"
            case .nand: return "↑"
            case .nor: return "↓"
            case .openParen: return "("
            case .closeParen: return ")"
            }
        }
        
        var canEndExpression: Bool {
            switch self {
            case .variable, .closeParen: return true
            default: return false
            }
        }
        
        var canBeginExpression: Bool {
            switch self {
            case .variable, .openParen, .not: return true
            default: return false
            }
        }
    }
    
    // MARK: - Публичный интерфейс
    
    /// Анализирует строку и возвращает ParsedFormula либо выбрасывает понятную ошибку
    static func parse(_ input: String) throws -> ParsedFormula {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ExpressionParserError.emptyExpression
        }
        
        let tokens = try tokenize(trimmed)
        guard !tokens.isEmpty else {
            throw ExpressionParserError.emptyExpression
        }
        
        let parser = ExpressionParser(tokens: tokens)
        let tree = try parser.parseExpression()
        
        if parser.currentIndex < parser.tokens.count {
            let nextToken = parser.tokens[parser.currentIndex]
            if nextToken == .closeParen {
                throw ExpressionParserError.unexpectedClosingParenthesis
            } else {
                let prevToken = parser.tokens[parser.currentIndex - 1]
                throw ExpressionParserError.missingOperator(between: prevToken.description, and: nextToken.description)
            }
        }
        
        let variables = extractVariables(from: tree)
        guard !variables.isEmpty else {
            throw ExpressionParserError.noVariables
        }
        
        if variables.count > maxVariablesCount {
            throw ExpressionParserError.tooManyVariables(count: variables.count, max: maxVariablesCount)
        }
        
        return ParsedFormula(
            expression: tree,
            expressionString: tree.description,
            variables: variables
        )
    }
    
    // MARK: - Токенизация
    
    private static func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        var iterator = input.enumerated().makeIterator()
        
        while let (idx, char) = iterator.next() {
            if char.isWhitespace { continue }
            
            switch char {
            case "A"..."Z":
                tokens.append(.variable(char))
            case "a"..."z":
                // Приводим строчные латинские буквы к верхнему регистру
                tokens.append(.variable(Character(char.uppercased())))
            case "(", "[":
                tokens.append(.openParen)
            case ")", "]":
                tokens.append(.closeParen)
            case "¬", "~", "!":
                tokens.append(.not)
            case "∧", "&", "*":
                tokens.append(.and)
            case "∨", "|", "+":
                tokens.append(.or)
            case "⊕", "^":
                tokens.append(.xor)
            case "→":
                tokens.append(.implies)
            case "↔", "≡", "=":
                tokens.append(.equivalent)
            case "↑":
                tokens.append(.nand)
            case "↓":
                tokens.append(.nor)
            case "-":
                // Проверяем стрелку ->
                if let next = input.enumerated().first(where: { $0.offset == idx + 1 })?.element, next == ">" {
                    _ = iterator.next() // пропускаем '>'
                    tokens.append(.implies)
                } else {
                    throw ExpressionParserError.unexpectedCharacter(char, position: idx)
                }
            case "<":
                // Проверяем стрелку <->
                if let next1 = input.enumerated().first(where: { $0.offset == idx + 1 })?.element, next1 == "-",
                   let next2 = input.enumerated().first(where: { $0.offset == idx + 2 })?.element, next2 == ">" {
                    _ = iterator.next()
                    _ = iterator.next()
                    tokens.append(.equivalent)
                } else {
                    throw ExpressionParserError.unexpectedCharacter(char, position: idx)
                }
            default:
                throw ExpressionParserError.unexpectedCharacter(char, position: idx)
            }
        }
        
        // Валидация соседних операндов без оператора: e.g. "A B" или "A (B)" или ") A"
        for i in 0..<(tokens.count - 1) {
            let current = tokens[i]
            let next = tokens[i + 1]
            
            // Если конец подвыражения идет сразу перед началом нового без знака операции
            if current.canEndExpression && next.canBeginExpression {
                throw ExpressionParserError.missingOperator(between: current.description, and: next.description)
            }
        }
        
        return tokens
    }
    
    // MARK: - Парсинг методом рекурсивного спуска
    
    private let tokens: [Token]
    private var currentIndex = 0
    
    private init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    private var currentToken: Token? {
        guard currentIndex < tokens.count else { return nil }
        return tokens[currentIndex]
    }
    
    private func advance() -> Token? {
        let t = currentToken
        currentIndex += 1
        return t
    }
    
    /// Expression -> Implication
    private func parseExpression() throws -> ExpressionNode {
        return try parseEquivalent()
    }
    
    /// Equivalence: A ↔ B ↔ C (левоассоциативно)
    private func parseEquivalent() throws -> ExpressionNode {
        var left = try parseImplies()
        
        while let token = currentToken, token == .equivalent {
            _ = advance()
            guard currentToken != nil else {
                throw ExpressionParserError.expectedOperand(after: token.description)
            }
            let right = try parseImplies()
            left = .binary(.equivalent, left, right)
        }
        return left
    }
    
    /// Implication: A → B → C (правоассоциативно: A → (B → C))
    private func parseImplies() throws -> ExpressionNode {
        let left = try parseOrXorNor()
        
        if let token = currentToken, token == .implies {
            _ = advance()
            guard currentToken != nil else {
                throw ExpressionParserError.expectedOperand(after: token.description)
            }
            let right = try parseImplies()
            return .binary(.implies, left, right)
        }
        return left
    }
    
    /// Or, Xor, Nor: ∨, ⊕, ↓ (левоассоциативно)
    private func parseOrXorNor() throws -> ExpressionNode {
        var left = try parseAndNand()
        
        while let token = currentToken {
            let op: LogicOperation
            switch token {
            case .or: op = .or
            case .xor: op = .xor
            case .nor: op = .nor
            default:
                return left
            }
            
            _ = advance()
            guard currentToken != nil else {
                throw ExpressionParserError.expectedOperand(after: token.description)
            }
            let right = try parseAndNand()
            left = .binary(op, left, right)
        }
        return left
    }
    
    /// And, Nand: ∧, ↑ (левоассоциативно)
    private func parseAndNand() throws -> ExpressionNode {
        var left = try parseUnary()
        
        while let token = currentToken {
            let op: LogicOperation
            switch token {
            case .and: op = .and
            case .nand: op = .nand
            default:
                return left
            }
            
            _ = advance()
            guard currentToken != nil else {
                throw ExpressionParserError.expectedOperand(after: token.description)
            }
            let right = try parseUnary()
            left = .binary(op, left, right)
        }
        return left
    }
    
    /// Unary: ¬ Unary | Primary
    private func parseUnary() throws -> ExpressionNode {
        guard let token = currentToken else {
            throw ExpressionParserError.expectedOperand(after: "выражение")
        }
        
        if token == .not {
            _ = advance()
            guard currentToken != nil else {
                throw ExpressionParserError.expectedOperand(after: "¬")
            }
            let operand = try parseUnary()
            return .negation(operand)
        }
        
        return try parsePrimary()
    }
    
    /// Primary: Variable | ( Expression )
    private func parsePrimary() throws -> ExpressionNode {
        guard let token = currentToken else {
            throw ExpressionParserError.expectedOperand(after: "выражение")
        }
        
        switch token {
        case .variable(let char):
            _ = advance()
            return .variable(char)
            
        case .openParen:
            _ = advance()
            let expr = try parseExpression()
            guard let next = currentToken, next == .closeParen else {
                throw ExpressionParserError.expectedClosingParenthesis
            }
            _ = advance()
            return expr
            
        case .closeParen:
            throw ExpressionParserError.unexpectedClosingParenthesis
            
        default:
            throw ExpressionParserError.expectedOperand(after: token.description)
        }
    }
    
    // MARK: - Вспомогательное извлечение переменных
    
    private static func extractVariables(from node: ExpressionNode) -> [Character] {
        var set: Set<Character> = []
        
        func collect(_ n: ExpressionNode) {
            switch n {
            case .variable(let c):
                set.insert(c)
            case .constant:
                break
            case .negation(let inner):
                collect(inner)
            case .binary(_, let l, let r):
                collect(l)
                collect(r)
            }
        }
        
        collect(node)
        return Array(set).sorted()
    }
}
