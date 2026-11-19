import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var theoryButton: UIButton!
    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var truthTableButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        theoryButton?.layer.cornerRadius = 10
        startButton?.layer.cornerRadius = 10 // скос
        truthTableButton?.layer.cornerRadius = 10
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTrainer" {
            if let trainerVC = segue.destination as? TrainerViewController {
                let selectedIndex = difficultySegmentedControl.selectedSegmentIndex + 1
                trainerVC.selectedDifficulty = Difficulty(rawValue: selectedIndex) ?? .medium
            }
        } else if segue.identifier == "showTruthTable" {
            if let truthTableVC = segue.destination as? TruthTableViewController {
                let selectedIndex = difficultySegmentedControl.selectedSegmentIndex + 1
                truthTableVC.selectedDifficulty = Difficulty(rawValue: selectedIndex) ?? .medium
            }
        }
    }
}
