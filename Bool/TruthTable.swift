import Foundation

/// Строка таблицы истинности
struct TruthTableRow: Equatable {
    /// Значения входных переменных для данной строки (например, ["A": false, "B": true])
    let inputs: [Character: Bool]
    
    /// Эталонное вычисленное значение функции
    let expectedOutput: Bool
    
    /// Ответ пользователя: nil (еще не дан), false (0), true (1)
    var userOutput: Bool?
    
    /// Заполнена ли строка пользователем
    var isFilled: Bool {
        return userOutput != nil
    }
    
    /// Правильно ли пользователь вычислил значение
    var isCorrect: Bool {
        guard let userOutput = userOutput else { return false }
        return userOutput == expectedOutput
    }
}

/// Модель таблицы истинности для логического выражения
struct TruthTable: Equatable {
    
    let expression: ExpressionNode
    let expressionString: String
    let variables: [Character] // отсортированные уникальные переменные (например, ["A", "B"])
    var rows: [TruthTableRow]
    
    // MARK: - Инициализация
    
    init(expression: ExpressionNode, expressionString: String, variables: [Character]) {
        self.expression = expression
        self.expressionString = expressionString
        self.variables = variables.sorted()
        self.rows = Self.generateRows(for: expression, variables: self.variables)
    }
    
    init(generated: ExpressionGenerator.GeneratedExpression) {
        self.init(
            expression: generated.tree,
            expressionString: generated.expression,
            variables: generated.variables
        )
    }
    
    // MARK: - Генерация строк (2^n)
    
    /// Генерирует все 2^n строк таблицы в каноническом лексикографическом порядке (00..0, 00..1, ..., 11..1)
    static func generateRows(for node: ExpressionNode, variables: [Character]) -> [TruthTableRow] {
        let n = variables.count
        guard n > 0 else { return [] }
        let totalRows = 1 << n // 2^n
        
        var result: [TruthTableRow] = []
        for i in 0..<totalRows {
            var inputs: [Character: Bool] = [:]
            for (bitIndex, variable) in variables.enumerated() {
                // Старший бит соответствует первой переменной слева
                let shift = n - 1 - bitIndex
                let bit = (i >> shift) & 1
                inputs[variable] = (bit == 1)
            }
            let expected = node.evaluate(with: inputs)
            result.append(TruthTableRow(inputs: inputs, expectedOutput: expected, userOutput: nil))
        }
        return result
    }
    
    // MARK: - Фабричный метод генерации под уровень сложности
    
    /// Генерирует таблицу истинности для заданного уровня сложности
    /// Для легкого и среднего уровней гарантирует не менее 2 переменных (4 строки)
    /// Параметр excluding позволяет исключить уже использованные выражения, чтобы избежать повторов
    static func generate(difficulty: Difficulty, excluding: Set<String> = []) -> TruthTable {
        var attempts = 0
        var generated: ExpressionGenerator.GeneratedExpression
        
        repeat {
            generated = ExpressionGenerator.generateExpression(difficulty: difficulty)
            attempts += 1
        } while (generated.variables.count < 2 || excluding.contains(generated.expression)) && attempts < 50
        
        return TruthTable(generated: generated)
    }
    
    // MARK: - Управление ответами пользователя
    
    /// Установить ответ пользователя для конкретной строки
    mutating func setUserOutput(_ value: Bool?, forRowAt index: Int) {
        guard index >= 0 && index < rows.count else { return }
        rows[index].userOutput = value
    }
    
    /// Циклическое переключение ответа: nil -> 0 -> 1 -> 0
    mutating func toggleUserOutput(forRowAt index: Int) {
        guard index >= 0 && index < rows.count else { return }
        switch rows[index].userOutput {
        case .none:
            rows[index].userOutput = false
        case .some(false):
            rows[index].userOutput = true
        case .some(true):
            rows[index].userOutput = false
        }
    }
    
    // MARK: - Статистика и проверка
    
    /// Заполнены ли все строки
    var isFullyFilled: Bool {
        return rows.allSatisfy { $0.isFilled }
    }
    
    /// Количество правильных строк
    var correctRowCount: Int {
        return rows.filter { $0.isCorrect }.count
    }
    
    /// Общее количество строк (2^n)
    var totalRowCount: Int {
        return rows.count
    }
    
    /// Доля правильных ответов (0.0 ... 1.0)
    var accuracy: Double {
        guard totalRowCount > 0 else { return 0.0 }
        return Double(correctRowCount) / Double(totalRowCount)
    }
    
    /// Решена ли таблица безошибочно
    var isPerfect: Bool {
        return correctRowCount == totalRowCount
    }
    
    // MARK: - Преобразование в UserAnswer для ResultViewController
    
    /// Формирует массив UserAnswer для совместимости с экраном результатов
    func toUserAnswers() -> [UserAnswer] {
        return rows.map { row in
            let inputsStr = variables.map { v in
                let val = (row.inputs[v] ?? false) ? "1" : "0"
                return "\(v)=\(val)"
            }.joined(separator: ", ")
            
            let userStr = row.userOutput.map { $0 ? "1" : "0" } ?? "—"
            let correctStr = row.expectedOutput ? "1" : "0"
            let questionText = "[\(inputsStr)] для F = \(expressionString)"
            
            return UserAnswer(
                questionText: questionText,
                userAnswerText: userStr,
                correctAnswerText: correctStr,
                isCorrect: row.isCorrect
            )
        }
    }
}
