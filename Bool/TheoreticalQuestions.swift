import Foundation

struct TheoreticalQuestion {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String? // Пояснение для ответа
}

class TheoreticalQuestionBank {
    
    // Легкие теоретические вопросы
    static func getEasyQuestions() -> [TheoreticalQuestion] {
        return [
            TheoreticalQuestion(
                text: "Как называется операция, обозначаемая символом ∧?",
                options: ["ИЛИ", "И", "НЕ", "Исключающее ИЛИ"],
                correctAnswerIndex: 1,
                explanation: "∧ - это конъюнкция (логическое И)"
            ),
            TheoreticalQuestion(
                text: "Как называется операция, обозначаемая символом ∨?",
                options: ["И", "ИЛИ", "НЕ", "Импликация"],
                correctAnswerIndex: 1,
                explanation: "∨ - это дизъюнкция (логическое ИЛИ)"
            ),
            TheoreticalQuestion(
                text: "Как называется операция, обозначаемая символом ⊕?",
                options: ["Логическое И", "Логическое ИЛИ", "Исключающее ИЛИ", "Эквивалентность"],
                correctAnswerIndex: 2,
                explanation: "⊕ - это исключающее ИЛИ, которое истинно только когда операнды различны"
            ),
            TheoreticalQuestion(
                text: "Как называется операция, обозначаемая символом ↑ ?",
                options: ["штрих Шеффера", "стрелка Пирса ", "Исключающее ИЛИ", "Импликация"],
                correctAnswerIndex: 0,
                explanation: "↑ - это штрих Шеффера (NAND), эквивалентно ¬(A ∧ B)"
            ),
            TheoreticalQuestion(
                text: "Как называется операция, обозначаемая символом  ↓ ?",
                options: ["штрих Шеффера", "стрелка Пирса ", "Исключающее ИЛИ", "Эквивалентность"],
                correctAnswerIndex: 1,
                explanation: "↓ - это стрелка Пирса (NOR), эквивалентно ¬(A ∨ B)"
            ),
            TheoreticalQuestion(
                text: "Сколько значений может принимать булева переменная?",
                options: ["1", "2", "3", "Бесконечно много"],
                correctAnswerIndex: 1,
                explanation: "Булева переменная может быть только True (истина) или False (ложь)"
            ),
            TheoreticalQuestion(
                text: "Что означает ¬A?",
                options: ["A и B", "A или B", "Отрицание A", "A → B"],
                correctAnswerIndex: 2,
                explanation: "¬A (NOT A) - это логическое отрицание (инверсия)"
            ),
            TheoreticalQuestion(
                text: "Чему равно 0 ∨ 1?",
                options: ["1", "0", "1 и 0", "Не определено"],
                correctAnswerIndex: 0,
                explanation: "0 ∨ 1 = 1"
            ),
            TheoreticalQuestion(
                text: "Что означает выражение\n 'A ⊕ B'?",
                options: ["A и B", "A или B", "A исключающее ИЛИ B", "Не A"],
                correctAnswerIndex: 2,
                explanation: "⊕ (исключающее ИЛИ) истинно, когда операнды различны"
            ),
            TheoreticalQuestion(
                text: "Сколько строк в таблице истинности для двух переменных?",
                options: ["2", "4", "8", "16"],
                correctAnswerIndex: 1,
                explanation: "Для n переменных таблица имеет 2^n строк. Для 2 переменных: 2^2 = 4"
            ),
            TheoreticalQuestion(
                text: "Какая операция имеет наивысший приоритет?",
                options: ["∧ (И)", "∨ (ИЛИ)", "¬ (НЕ)", "→ (импликация)"],
                correctAnswerIndex: 2,
                explanation: "Отрицание (¬) имеет наивысший приоритет, выполняется первым, как 'минус' в математике"
            ),
            TheoreticalQuestion(
                text: "Чему равноn ¬(¬A)?",
                options: ["A", "¬A", "Всегда 0", "Всегда 1"],
                correctAnswerIndex: 0,
                explanation: "¬(¬A) = A — это закон двойного отрицания"
            ),
            TheoreticalQuestion(
                text: "Какая операция является отрицанием AND?",
                options: ["OR", "NOR", "NAND", "XOR"],
                correctAnswerIndex: 2,
                explanation: "NAND (штрих Шеффера) — это отрицание AND: NAND = ¬(A ∧ B)"
            )

        ]
    }
    
    // Средние теоретические вопросы
    static func getMediumQuestions() -> [TheoreticalQuestion] {
        return [
            TheoreticalQuestion(
                text: "Какой закон утверждает,\n что A ∧ B = B ∧ A?",
                options: ["Закон поглощения", "Закон коммутативности", "Закон ассоциативности", "Закон де Моргана"],
                correctAnswerIndex: 1,
                explanation: "Коммутативность - это свойство перестановки операндов"
            ),
            TheoreticalQuestion(
                text: "Какой закон утверждает,\n что A ∨ (B ∨ C) = (A ∨ B) ∨ C?",
                options: ["Закон коммутативности", "Закон ассоциативности", "Закон дистрибутивности", "Закон де Моргана"],
                correctAnswerIndex: 1,
                explanation: "Ассоциативность позволяет менять порядок вычислений"
            ),

            TheoreticalQuestion(
                text: "Какой закон описывает равенство\n A ∧ (B ∨ C) = (A ∧ B) ∨ (A ∧ C)?",
                options: ["Коммутативность", "Ассоциативность", "Дистрибутивность И относительно ИЛИ", "Дистрибутивность ИЛИ относительно И"],
                correctAnswerIndex: 2,
                explanation: "Это закон дистрибутивности конъюнкции относительно дизъюнкции"
            ),
            TheoreticalQuestion(
                text: "Какая операция является двойственной к ∧?",
                options: ["∨", "¬", "⊕", "↑"],
                correctAnswerIndex: 0,
                explanation: "По принципу двойственности, ∧ и ∨ являются двойственными операциями"
            ),
            TheoreticalQuestion(
                text: "Что такое булева функция?",
                options: ["Функция от действительных чисел", "Функция от булевых переменных, возвращающая булево значение", "Алгебраическое выражение", "Таблица истинности"],
                correctAnswerIndex: 1,
                explanation: "Булева функция принимает булевы аргументы и возвращает булево значение"
            ),
            TheoreticalQuestion(
                text: "Сколько существует различных булевых функций от двух переменных?",
                options: ["4", "8", "16", "32"],
                correctAnswerIndex: 2,
                explanation: "Для n переменных существует 2^(2^n) функций. Для n=2: 2^(4)=16"
            ),
            TheoreticalQuestion(
                text: "Чему равно A ⊕ A?",
                options: ["A", "¬A", "0", "1"],
                correctAnswerIndex: 2,
                explanation: "A ⊕ A = 0, потому что XOR даёт истину только когда операнды различны, а здесь они одинаковы"
            ),
            TheoreticalQuestion(
                text: "Чему равно A → A?",
                options: ["0", "1", "A", "¬A"],
                correctAnswerIndex: 1,
                explanation: "A → A — это тавтология, всегда истинно (1), потому что 'из A следует A' всегда верно"
            ),
            TheoreticalQuestion(
                text: "Какой закон утверждает, что A ∧ (A ∨ B) = A?",
                options: ["Закон идемпотентности", "Закон поглощения", "Закон склеивания", "Закон де Моргана"],
                correctAnswerIndex: 1,
                explanation: "A ∧ (A ∨ B) = A — это закон поглощения. Конъюнкция 'поглощает' дизъюнкцию"
            ),
            TheoreticalQuestion(
                text: "Какое выражение является тавтологией?",
                options: ["A ∧ ¬A", "A ∨ ¬A", "A → ¬A", "¬A → A"],
                correctAnswerIndex: 1,
                explanation: "A ∨ ¬A — закон исключённого третьего, всегда истинно (тавтология)"
            ),
            TheoreticalQuestion(
                text: "Какое выражение является противоречием?",
                options: ["A ∨ ¬A", "A → A", "A ∧ ¬A", "A ∨ A"],
                correctAnswerIndex: 2,
                explanation: "A ∧ ¬A — закон противоречия, всегда ложно (противоречие)"
            )
        ]
    }
    
    // Сложные теоретические вопросы
    static func getHardQuestions() -> [TheoreticalQuestion] {
        return [
            TheoreticalQuestion(
                text: "Как формулируется закон де Моргана для конъюнкции?",
                options: ["¬(A ∧ B) = ¬A ∨ ¬B", "¬(A ∧ B) = ¬A ∧ ¬B", "A ∧ (B ∨ C) = (A ∧ B) ∨ (A ∧ C)", "A ∨ (B ∧ C) = (A ∨ B) ∧ (A ∨ C)"],
                correctAnswerIndex: 0,
                explanation: "Первый закон де Моргана: отрицание конъюнкции равно дизъюнкции отрицаний"
            ),
            TheoreticalQuestion(
                text: "Как формулируется закон де Моргана для дизъюнкции?",
                options: ["¬(A ∨ B) = ¬A ∨ ¬B", "¬(A ∨ B) = ¬A ∧ ¬B", "A ∧ (B ∨ C) = (A ∧ B) ∨ (A ∧ C)", "A ∨ (B ∧ C) = (A ∨ B) ∧ (A ∨ C)"],
                correctAnswerIndex: 1,
                explanation: "Второй закон де Моргана: отрицание дизъюнкции равно конъюнкции отрицаний"
            ),
            TheoreticalQuestion(
                text: "Что такое функционально полная система булевых функций?",
                options: ["Набор функций, через которые можно выразить все остальные", "Набор функций, которые коммутируют", "Набор функций, которые ассоциативны", "Набор функций, которые дистрибутивны"],
                correctAnswerIndex: 0,
                explanation: "Функционально полная система позволяет выразить любую булеву функцию"
            ),
            TheoreticalQuestion(
                text: "Какая из этих систем является функционально полной?",
                options: ["{∧, ∨}", "{∧, ¬}", "{⊕, ∧}", "{→, ¬}"],
                correctAnswerIndex: 1,
                explanation: "{∧, ¬} и {∨, ¬} являются функционально полными. Одного ∧ и OR недостаточно"
            ),
            TheoreticalQuestion(
                text: "Что такое СДНФ?",
                options: ["Совершенная дизъюнктивная нормальная форма", "Совершенная конъюнктивная нормальная форма", "Стандартная дизъюнктивная форма", "Сокращенная дизъюнктивная форма"],
                correctAnswerIndex: 0,
                explanation: "СДНФ - это дизъюнкция полных конъюнкций (минтермов)"
            ),
            TheoreticalQuestion(
                text: "Что такое СКНФ?",
                options: ["Совершенная дизъюнктивная нормальная форма", "Совершенная конъюнктивная нормальная форма", "Стандартная конъюнктивная форма", "Сокращенная конъюнктивная форма"],
                correctAnswerIndex: 1,
                explanation: "СКНФ - это конъюнкция полных дизъюнкций (макстермов)"
            ),
            TheoreticalQuestion(
                text: "Что такое карта Карно?",
                options: ["Графический метод минимизации булевых функций", "Таблица истинности", "Логическая схема", "Алгоритм упрощения"],
                correctAnswerIndex: 0,
                explanation: "Карта Карно позволяет визуально минимизировать булевы функции до 6 переменных"
            ),
            TheoreticalQuestion(
                text: "Какой закон утверждает,\n что A ∧ (A ∨ B) = A?",
                options: ["Закон поглощения", "Закон идемпотентности", "Закон склеивания", "Закон де Моргана"],
                correctAnswerIndex: 0,
                explanation: "A ∧ (A ∨ B) = A - это закон поглощения конъюнкцией дизъюнкции"
            ),
            TheoreticalQuestion(
                text: "Как упростить выражение (A ∨ B) ∧ (A ∨ ¬B)?",
                options: ["A", "B", "A ∧ B", "A ∨ B"],
                correctAnswerIndex: 0,
                explanation: "(A ∨ B) ∧ (A ∨ ¬B) = A ∨ (B ∧ ¬B) = A ∨ 0 = A"
            ),
            TheoreticalQuestion(
                text: "Как упростить выражение (A ∧ B) ∨ (A ∧ ¬B) ∨ (¬A ∧ B)?",
                options: ["A ∨ B", "A ∧ B", "A ⊕ B", "A → B"],
                correctAnswerIndex: 2,
                explanation: "Это выражение равно A ⊕ B (исключающее ИЛИ), потому что оно истинно когда A и B различны"
            ),
            TheoreticalQuestion(
                text: "Чему равно (A → B) → A?",
                options: ["A", "B", "A ∧ B", "A ∨ B"],
                correctAnswerIndex: 0,
                explanation: "Это закон Пирса: (A → B) → A = A, независимо от B"
            ),
            TheoreticalQuestion(
                text: "Что такое 'дизъюнктивная нормальная форма' (ДНФ)?",
                options: ["Дизъюнкция конъюнкций", "Конъюнкция дизъюнкций", "Дизъюнкция переменных", "Конъюнкция переменных"],
                correctAnswerIndex: 0,
                explanation: "ДНФ — это дизъюнкция (ИЛИ) нескольких конъюнкций (И), например: (A∧B) ∨ (C∧¬D)"
            )

        ]
    }
}
