import UIKit

/// Контроллер режима «Таблицы истинности»
class TruthTableViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var expressionFormulaLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    // MARK: - Публичные свойства
    var selectedDifficulty: Difficulty = .medium
    var customTable: TruthTable?
    
    // MARK: - Приватное состояние
    private var totalTablesCount = 3
    private var tables: [TruthTable] = []
    private var currentTableIndex = 0
    private var isTableChecked = false
    private var completedTableIndices: Set<Int> = []
    
    private var truthTable: TruthTable? {
        get {
            guard tables.indices.contains(currentTableIndex) else { return nil }
            return tables[currentTableIndex]
        }
        set {
            if let newValue = newValue, tables.indices.contains(currentTableIndex) {
                tables[currentTableIndex] = newValue
            }
        }
    }
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        // Скругления кнопок в фирменном стиле приложения
        actionButton?.layer.cornerRadius = 10
        finishButton?.layer.cornerRadius = 10
        exitButton?.layer.cornerRadius = 10
        
        setupTableView()
        setupSession()
    }
    
    // MARK: - Настройка компонентов
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TruthTableRowCell.self, forCellReuseIdentifier: TruthTableRowCell.identifier)
        tableView.rowHeight = 44
        tableView.backgroundColor = .white
    }
    
    // MARK: - Загрузка и управление тестом
    
    /// Генерирует все таблицы для текущей сессии с гарантией неповторяющихся выражений
    private func setupSession() {
        tables.removeAll()
        completedTableIndices.removeAll()
        
        if let customTable = customTable {
            totalTablesCount = 1
            tables.append(customTable)
        } else {
            totalTablesCount = 3
            var usedExpressions: Set<String> = []
            for _ in 0..<totalTablesCount {
                let table = TruthTable.generate(difficulty: selectedDifficulty, excluding: usedExpressions)
                usedExpressions.insert(table.expressionString)
                tables.append(table)
            }
        }
        currentTableIndex = 0
        displayCurrentTable()
    }
    
    private func displayCurrentTable() {
        guard let table = truthTable else { return }
        isTableChecked = false
        
        if customTable != nil {
            counterLabel?.text = "Своя формула"
            difficultyLabel?.text = "Пользовательский ввод"
        } else {
            counterLabel?.text = "Таблица \(currentTableIndex + 1) из \(totalTablesCount)"
            difficultyLabel?.text = "Сложность: \(selectedDifficulty.description)"
        }
        expressionFormulaLabel?.text = "F = \(table.expressionString)"
        instructionLabel?.text = "Заполните столбец F для всех наборов:"
        
        actionButton?.setTitle("Ответить", for: .normal)
        actionButton?.backgroundColor = UIColor(named: "AccentColor") ?? .systemBlue
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if !isTableChecked {
            checkCurrentTable()
        } else {
            if currentTableIndex < totalTablesCount - 1 {
                currentTableIndex += 1
                displayCurrentTable()
            } else {
                showResults()
            }
        }
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        if !isTableChecked && (truthTable?.rows.contains(where: { $0.isFilled }) == true) {
            checkCurrentTable()
        }
        showResults()
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Проверка и передача данных
    
    private func checkCurrentTable() {
        guard let table = truthTable else { return }
        isTableChecked = true
        completedTableIndices.insert(currentTableIndex)
        tableView.reloadData()
        
        let correct = table.correctRowCount
        let total = table.totalRowCount
        
        if currentTableIndex < totalTablesCount - 1 {
            actionButton?.setTitle("Следующая (\(correct)/\(total))", for: .normal)
        } else {
            actionButton?.setTitle("Завершить (\(correct)/\(total))", for: .normal)
        }
        actionButton?.backgroundColor = (correct == total) ? .systemGreen : (UIColor(named: "AccentColor") ?? .systemBlue)
    }
    
    private func showResults() {
        guard !tables.isEmpty else {
            dismiss(animated: true)
            return
        }
        performSegue(withIdentifier: "showResult", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            if let resultVC = segue.destination as? ResultViewController {
                let completedTables = completedTableIndices.sorted().compactMap { index -> TruthTable? in
                    guard tables.indices.contains(index) else { return nil }
                    return tables[index]
                }
                let displayedAnswers = completedTables.flatMap { $0.toUserAnswers() }
                let totalSessionQuestions = tables.reduce(0) { $0 + $1.totalRowCount }
                
                resultVC.score = displayedAnswers.filter { $0.isCorrect }.count
                resultVC.totalQuestions = totalSessionQuestions
                resultVC.userAnswers = displayedAnswers
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TruthTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return truthTable?.totalRowCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let table = truthTable else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGray5
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        headerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: headerView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        // Колонки входных переменных (A, B, C...)
        for v in table.variables {
            let label = UILabel()
            label.text = String(v)
            label.textAlignment = .center
            label.font = UIFont(name: "Copperplate", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold)
            label.textColor = .black
            stack.addArrangedSubview(label)
        }
        
        // Колонка результата F
        let resultHeader = UILabel()
        resultHeader.text = "F"
        resultHeader.textAlignment = .center
        resultHeader.font = UIFont(name: "Copperplate", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        resultHeader.textColor = UIColor(named: "AccentColor") ?? .systemBlue
        stack.addArrangedSubview(resultHeader)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TruthTableRowCell.identifier, for: indexPath) as? TruthTableRowCell,
              let table = truthTable,
              indexPath.row < table.rows.count else {
            return UITableViewCell()
        }
        
        let row = table.rows[indexPath.row]
        cell.configure(
            variables: table.variables,
            row: row,
            isChecked: isTableChecked,
            onSegmentChanged: { [weak self] selectedValue in
                guard let self = self, !self.isTableChecked else { return }
                guard self.tables.indices.contains(self.currentTableIndex) else { return }
                self.tables[self.currentTableIndex].setUserOutput(selectedValue, forRowAt: indexPath.row)
            }
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard isTableChecked, let table = truthTable, indexPath.row < table.rows.count else { return }
        
        let row = table.rows[indexPath.row]
        let inputsStr = table.variables.map { v in
            let val = (row.inputs[v] ?? false) ? "1" : "0"
            return "\(v) = \(val)"
        }.joined(separator: ", ")
        
        let userStr = row.userOutput.map { $0 ? "1" : "0" } ?? "не указан"
        let correctStr = row.expectedOutput ? "1" : "0"
        
        let alert = UIAlertController(
            title: row.isCorrect ? "Правильно!" : "Ошибка в строке",
            message: """
            При наборе: \(inputsStr)
            Ваш ответ: \(userStr)
            Правильный ответ: \(correctStr)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Ячейка строки таблицы истинности
class TruthTableRowCell: UITableViewCell {
    
    static let identifier = "TruthTableRowCell"
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["0", "1"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor.systemGray6
        return sc
    }()
    
    private var onSegmentChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
    }
    
    @objc private func segmentValueChanged() {
        let value = (segmentedControl.selectedSegmentIndex == 1)
        onSegmentChanged?(value)
    }
    
    func configure(
        variables: [Character],
        row: TruthTableRow,
        isChecked: Bool,
        onSegmentChanged: @escaping (Bool) -> Void
    ) {
        self.onSegmentChanged = onSegmentChanged
        
        stackView.arrangedSubviews.forEach { view in
            if view !== segmentedControl {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        
        for v in variables {
            let label = UILabel()
            let val = (row.inputs[v] ?? false) ? "1" : "0"
            label.text = val
            label.textAlignment = .center
            label.font = UIFont(name: "Copperplate", size: 18) ?? UIFont.systemFont(ofSize: 18)
            label.textColor = .black
            stackView.addArrangedSubview(label)
        }
        
        stackView.addArrangedSubview(segmentedControl)
        
        if let userOutput = row.userOutput {
            segmentedControl.selectedSegmentIndex = userOutput ? 1 : 0
        } else {
            segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        segmentedControl.isEnabled = !isChecked
        
        if isChecked {
            if row.isCorrect {
                backgroundColor = UIColor.green.withAlphaComponent(0.2)
            } else {
                backgroundColor = UIColor.red.withAlphaComponent(0.2)
            }
        } else {
            backgroundColor = .white
        }
    }
}
