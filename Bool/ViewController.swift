import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var theoryButton: UIButton!
    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light
        theoryButton.layer.cornerRadius = 10
        startButton.layer.cornerRadius = 10// скос
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//Этот метод вызывается перед тем, как произойдет переход на другой экран. 
        if segue.identifier == "showTrainer" {
            if let trainerVC = segue.destination as? TrainerViewController {
                // Передаем выбранную сложность
                let selectedIndex = difficultySegmentedControl.selectedSegmentIndex + 1
                trainerVC.selectedDifficulty = Difficulty(rawValue: selectedIndex) ?? .medium
            }
        }
    }
}
