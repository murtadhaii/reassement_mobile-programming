//
//  IntroductionViewController.swift
//  MovieGenreQuiz
//
//  Created for IT8108 Re-Assessment
//

import UIKit

class IntroductionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var quizSelectionStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var historyButton: UIButton!
    
    // MARK: - Properties
    var selectedQuiz: Quiz?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createQuizButtons()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        
        // Title styling
        titleLabel.text = "Personality Quizzes"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.16, alpha: 1.0)
        
        // Subtitle styling
        subtitleLabel.text = "Discover your personality!"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        
        // History button styling
        historyButton.setTitle("View History", for: .normal)
        historyButton.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0), for: .normal)
        historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func createQuizButtons() {
        // Clear existing arranged subviews
        quizSelectionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for quiz in Quiz.allQuizzes {
            let button = createQuizButton(for: quiz)
            quizSelectionStackView.addArrangedSubview(button)
        }
    }
    
    func createQuizButton(for quiz: Quiz) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(quiz.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        // Shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        
        button.addTarget(self, action: #selector(quizButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    @objc func quizButtonTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text,
              let quiz = Quiz.allQuizzes.first(where: { $0.title == buttonTitle }) else {
            return
        }
        
        selectedQuiz = quiz
        performSegue(withIdentifier: "beginQuiz", sender: nil)
    }
    
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showHistory", sender: nil)
    }
    
    @IBAction func unwindToQuizIntroduction(segue: UIStoryboardSegue) {
        // Unwind action - dismisses quiz and returns here
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "beginQuiz",
           let navController = segue.destination as? UINavigationController,
           let questionVC = navController.topViewController as? QuestionViewController {
            questionVC.quiz = selectedQuiz
        }
    }
}
