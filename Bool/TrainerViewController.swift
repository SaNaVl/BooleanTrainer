import UIKit

class TrainerViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var questionCounterLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var finalButton: UIButton!
    
    // MARK: - Properties
    var selectedDifficulty: Difficulty = .medium
    private var questions: [Question] = []
    private var currentQuestionIndex = 0
    private var selectedAnswerIndex: Int?
    private var score = 0
    private var userAnswers: [UserAnswer] = []
    private var isTestCompleted = false // Флаг завершения теста
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupUI()
        loadQuestions()
        updateUI()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnswerCell")
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        
        actionButton.layer.cornerRadius = 10
        actionButton.isEnabled = false
        actionButton.backgroundColor = .gray
        
        finalButton.layer.cornerRadius = 10
        
        exitButton.layer.cornerRadius = 10
    }
    
    private func loadQuestions() {
        questions = QuestionBank.getQuestions(for: selectedDifficulty)
    }
    
    private func updateUI() {
        // Проверяем, не завершен ли тест
        if isTestCompleted {
            return
        }
        
        // Проверяем, есть ли еще вопросы
        if currentQuestionIndex < questions.count {
            questionCounterLabel.text = "Вопрос \(currentQuestionIndex + 1) из \(questions.count)"
            difficultyLabel.text = "Сложность: \(selectedDifficulty.description)"
            questionTextLabel.text = questions[currentQuestionIndex].text
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            // Вопросы закончились, показываем сообщение
            questionTextLabel.text = "Все вопросы пройдены! Нажмите Завершить"
            tableView.isHidden = true
            actionButton.isEnabled = false
            actionButton.backgroundColor = .gray
        }
    }
    
    private func saveCurrentAnswer() {
        // Проверяем, что индекс в пределах массива
        guard currentQuestionIndex < questions.count,
              let selectedIndex = selectedAnswerIndex else {
            return
        }
        
        let currentQ = questions[currentQuestionIndex]
        let isCorrect = selectedIndex == currentQ.correctAnswerIndex
        
        if isCorrect {
            score += 1
        }
        
        let userAnswer = UserAnswer(
            questionText: currentQ.text,
            userAnswerText: currentQ.options[selectedIndex],
            correctAnswerText: currentQ.options[currentQ.correctAnswerIndex],
            isCorrect: isCorrect
        )
        userAnswers.append(userAnswer)
    }
    
    private func moveToNextQuestion() {
        // Сохраняем ответ на текущий вопрос
        saveCurrentAnswer()
        
        // Переходим к следующему вопросу
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            actionButton.isEnabled = false
            actionButton.backgroundColor = .gray
            updateUI()
        } else {
            // Это был последний вопрос, отмечаем что тест завершен
            currentQuestionIndex += 1 // Увеличиваем индекс, чтобы показать, что вопросы кончились
            selectedAnswerIndex = nil
            updateUI() // Покажем сообщение о завершении
        }
    }
    
    private func finishTest() {
        guard !isTestCompleted else { return }
        isTestCompleted = true
        
        if currentQuestionIndex < questions.count && selectedAnswerIndex != nil {
            saveCurrentAnswer()
        }
        
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    // Передаём данные перед переходом
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            if let resultVC = segue.destination as? ResultViewController {
                resultVC.score = score
                resultVC.totalQuestions = questions.count
                resultVC.userAnswers = userAnswers
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        // Проверяем, что есть выбранный ответ и мы еще не завершили тест
        guard !isTestCompleted,
              selectedAnswerIndex != nil,
              currentQuestionIndex < questions.count else {
            return
        }
        
        moveToNextQuestion()
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func finalButtonTapped(_ sender: UIButton) {
        finishTest()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TrainerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Сколько строк (ячеек) нужно показать
        // Если вопросы закончились или тест завершен, не показываем варианты
        guard !isTestCompleted,
              currentQuestionIndex < questions.count else {
            return 0
        }
        return questions[currentQuestionIndex].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Создаёт или переиспользует ячейку для конкретной строки и заполняет её данными.
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        guard currentQuestionIndex < questions.count,
              indexPath.row < questions[currentQuestionIndex].options.count else {
            cell.textLabel?.text = ""
            return cell
        }
        
        let option = questions[currentQuestionIndex].options[indexPath.row]
        cell.textLabel?.text = option
        cell.textLabel?.numberOfLines = 0 // Разрешаем многострочный текст
        cell.textLabel?.lineBreakMode = .byWordWrapping // Перенос по словам
        cell.accessoryType = (indexPath.row == selectedAnswerIndex) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Реагирует на нажатие на строку
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Проверяем, что мы еще не завершили тест
        guard !isTestCompleted,
              currentQuestionIndex < questions.count else {
            return
        }
        
        selectedAnswerIndex = indexPath.row
        actionButton.isEnabled = true
        actionButton.backgroundColor = .systemBlue
        tableView.reloadData()
    }
}
