import UIKit

class ResultViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var score = 0
    var totalQuestions = 0
    var userAnswers: [UserAnswer] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupUI()
        exitButton.layer.cornerRadius = 10
    }
    
    private func setupUI() {
        scoreLabel.text = "Результат: \(score)/\(totalQuestions)"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        // Возвращаемся на главный экран
        view.window?.rootViewController?.dismiss(animated: true)
        // или если есть navigationController:
        // navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let answer = userAnswers[indexPath.row]
        
        cell.textLabel?.text = "Вопрос \(indexPath.row + 1): \(answer.questionText)"
        cell.textLabel?.numberOfLines = 0
        
        if answer.isCorrect {
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let answer = userAnswers[indexPath.row]
        
        let message = """
        Ваш ответ: \(answer.userAnswerText)
        Правильный ответ: \(answer.correctAnswerText)
        """
        
        let alert = UIAlertController(
            title: answer.isCorrect ? "✅ Правильно" : "❌ Неправильно",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
