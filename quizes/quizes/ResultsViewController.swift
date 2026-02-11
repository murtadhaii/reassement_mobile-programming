//
//  ResultsViewController.swift
//  MovieGenreQuiz
//
//  Created for IT8108 Re-Assessment
//

import UIKit

class ResultsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var resultAnswerLabel: UILabel!
    @IBOutlet var resultDefinitionLabel: UILabel!
    
    // MARK: - Properties
    var responses: [Answer] = []
    var quizTitle: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Results"
        
        calculatePersonalityResult()
    }
    
    // MARK: - Result Calculation
    func calculatePersonalityResult() {
        let frequencyOfAnswers = responses.reduce(into: [:]) { counts, answer in
            counts[answer.type, default: 0] += 1
        }
        
        let mostCommonAnswer = frequencyOfAnswers.sorted { $0.1 > $1.1 }.first!.key
        
        // Use context-aware names and definitions based on quiz title
        resultAnswerLabel.text = "You are \(mostCommonAnswer.displayName(for: quizTitle))!"
        resultDefinitionLabel.text = mostCommonAnswer.definition(for: quizTitle)
        
        // Save to history (Stretch Goal #4)
        saveQuizResult(genre: mostCommonAnswer)
    }
    
    // MARK: - History Storage (Stretch Goal #4)
    func saveQuizResult(genre: MovieGenre) {
        let result = QuizResult(
            quizTitle: quizTitle,
            result: genre.displayName(for: quizTitle),
            resultDefinition: genre.definition(for: quizTitle),
            date: Date(),
            emoji: String(genre.rawValue)
        )
        
        var history = loadQuizHistory()
        history.append(result)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "quizHistory")
        }
    }
    
    func loadQuizHistory() -> [QuizResult] {
        if let data = UserDefaults.standard.data(forKey: "quizHistory"),
           let history = try? JSONDecoder().decode([QuizResult].self, from: data) {
            return history
        }
        return []
    }
    
    // MARK: - Actions
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
