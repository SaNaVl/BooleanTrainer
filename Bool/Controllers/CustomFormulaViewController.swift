import UIKit

/// Контроллер режима «Своя формула» с интерфейсом из Storyboard
class CustomFormulaViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var formulaContainerView: UIView!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buildTableButton: UIButton!
    
    // MARK: - Состояние
    private var formulaText: String = "" {
        didSet {
            updateFormulaDisplay()
        }
    }
    private var preparedTruthTable: TruthTable?
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        setupStyling()
        updateFormulaDisplay()
    }
    
    private func setupStyling() {
        exitButton?.layer.cornerRadius = 10
        buildTableButton?.layer.cornerRadius = 10
        
        formulaContainerView?.layer.cornerRadius = 12
        formulaContainerView?.layer.borderWidth = 1
        formulaContainerView?.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    // MARK: - Обработка нажатий на кнопки клавиатуры
    
    @IBAction func keypadButtonTapped(_ sender: UIButton) {
        errorLabel?.text = ""
        guard let title = sender.configuration?.title ?? sender.title(for: .normal) else { return }
        
        switch title {
        case "A", "B", "C", "D":
            formulaText.append(title)
        case "(", ")":
            formulaText.append(title)
        case "¬":
            formulaText.append("¬")
        case "∧", "∨", "⊕", "→", "↔", "↑", "↓":
            if !formulaText.isEmpty && !formulaText.hasSuffix(" ") {
                formulaText.append(" \(title) ")
            } else {
                formulaText.append("\(title) ")
            }
        case "⌫":
            handleBackspace()
        case "Сброс":
            formulaText = ""
        default:
            break
        }
    }
    
    private func handleBackspace() {
        guard !formulaText.isEmpty else { return }
        if formulaText.hasSuffix(" ") {
            formulaText = String(formulaText.dropLast())
            if let last = formulaText.last, !last.isLetter && last != ")" && last != "(" {
                formulaText = String(formulaText.dropLast())
            }
            if formulaText.hasSuffix(" ") {
                formulaText = String(formulaText.dropLast())
            }
        } else {
            formulaText = String(formulaText.dropLast())
        }
    }
    
    private func updateFormulaDisplay() {
        guard let formulaLabel = formulaLabel else { return }
        if formulaText.isEmpty {
            formulaLabel.text = "Нажмите кнопки ниже..."
            formulaLabel.textColor = .placeholderText
        } else {
            formulaLabel.text = formulaText
            formulaLabel.textColor = .black
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func buildTableButtonTapped(_ sender: UIButton) {
        do {
            let parsed = try ExpressionParser.parse(formulaText)
            let table = TruthTable(
                expression: parsed.expression,
                expressionString: parsed.expressionString,
                variables: parsed.variables
            )
            
            preparedTruthTable = table
            performSegue(withIdentifier: "showCustomTruthTable", sender: nil)
        } catch {
            errorLabel?.text = error.localizedDescription
            shakeError()
        }
    }
    
    // MARK: - Навигация
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCustomTruthTable",
           let truthTableVC = segue.destination as? TruthTableViewController {
            truthTableVC.customTable = preparedTruthTable
        }
    }
    
    private func shakeError() {
        guard let container = formulaContainerView else { return }
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10.0, 10.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        container.layer.add(animation, forKey: "shake")
    }
}
