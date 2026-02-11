//
//  QuestionViewController.swift
//  MovieGenreQuiz
//
//  Created for IT8108 Re-Assessment
//

import UIKit

class QuestionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var singleStackView: UIStackView!
    @IBOutlet var multipleStackView: UIStackView!
    @IBOutlet var rangedStackView: UIStackView!
    @IBOutlet var questionProgressView: UIProgressView!
    @IBOutlet var timerLabel: UILabel!
    
    // Single answer outlets
    @IBOutlet var singleButton1: UIButton!
    @IBOutlet var singleButton2: UIButton!
    @IBOutlet var singleButton3: UIButton!
    @IBOutlet var singleButton4: UIButton!
    
    // Multiple answer outlets
    @IBOutlet var multiLabel1: UILabel!
    @IBOutlet var multiLabel2: UILabel!
    @IBOutlet var multiLabel3: UILabel!
    @IBOutlet var multiLabel4: UILabel!
    @IBOutlet var multiSwitch1: UISwitch!
    @IBOutlet var multiSwitch2: UISwitch!
    @IBOutlet var multiSwitch3: UISwitch!
    @IBOutlet var multiSwitch4: UISwitch!
    
    // Ranged answer outlets
    @IBOutlet var rangedLabel1: UILabel!
    @IBOutlet var rangedLabel2: UILabel!
    @IBOutlet var rangedSlider: UISlider!
    
    // MARK: - Properties
    var quiz: Quiz?
    var questions: [Question] = []
    var questionIndex = 0
    var answersChosen: [Answer] = []
    var currentShuffledAnswers: [Answer] = [] // Store shuffled answers for current question
    
    // Timer properties
    var questionTimer: Timer?
    var timeRemaining: Int = 30 // 30 seconds per question
    let questionTimeLimit: Int = 30
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let quiz = quiz {
            // Randomize questions (Stretch Goal #2)
            questions = quiz.questions.shuffled()
            navigationItem.title = quiz.title
        }
        
        updateUI()
        startQuestionTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopQuestionTimer()
    }
    
    // MARK: - Timer Functions (Stretch Goal #5)
    func startQuestionTimer() {
        timeRemaining = questionTimeLimit
        updateTimerLabel()
        
        questionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.updateTimerLabel()
            
            if self.timeRemaining <= 0 {
                self.stopQuestionTimer()
                self.handleTimeExpired()
            }
        }
    }
    
    func stopQuestionTimer() {
        questionTimer?.invalidate()
        questionTimer = nil
    }
    
    func updateTimerLabel() {
        timerLabel.text = "Time: \(timeRemaining)s"
        
        // Change color based on time remaining
        if timeRemaining <= 10 {
            timerLabel.textColor = .systemRed
        } else if timeRemaining <= 20 {
            timerLabel.textColor = .systemOrange
        } else {
            timerLabel.textColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
        }
    }
    
    func handleTimeExpired() {
        let alert = UIAlertController(
            title: "Time's Up!",
            message: "Moving to next question with no answer selected.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.nextQuestion()
        })
        present(alert, animated: true)
    }
    
    // MARK: - UI Update
    func updateUI() {
        singleStackView.isHidden = true
        multipleStackView.isHidden = true
        rangedStackView.isHidden = true
        
        let currentQuestion = questions[questionIndex]
        let currentAnswers = currentQuestion.answers
        let totalProgress = Float(questionIndex) / Float(questions.count)
        
        navigationItem.title = "Question #\(questionIndex + 1)"
        questionLabel.text = currentQuestion.text
        questionProgressView.setProgress(totalProgress, animated: true)
        
        // Randomize answers (Stretch Goal #2) and store them
        currentShuffledAnswers = currentAnswers.shuffled()
        
        switch currentQuestion.type {
        case .single:
            updateSingleStack(using: currentShuffledAnswers)
        case .multiple:
            updateMultipleStack(using: currentShuffledAnswers)
        case .ranged:
            updateRangedStack(using: currentShuffledAnswers)
        }
    }
    
    // MARK: - Single Answer Update (Dynamic - Stretch Goal #3)
    func updateSingleStack(using answers: [Answer]) {
        singleStackView.isHidden = false
        
        // Clear existing buttons
        singleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Store the shuffled answers for later retrieval
        // Create buttons dynamically based on number of answers
        for (index, answer) in answers.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(answer.text, for: .normal)
            button.tag = index  // Use index to retrieve from the shuffled array
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button.addTarget(self, action: #selector(singleAnswerButtonPressed(_:)), for: .touchUpInside)
            
            singleStackView.addArrangedSubview(button)
            
            // Add height constraint
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        }
    }
    
    // MARK: - Multiple Answer Update (Dynamic - Stretch Goal #3)
    func updateMultipleStack(using answers: [Answer]) {
        multipleStackView.isHidden = false
        
        // Clear existing content
        multipleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Store shuffled answers for later retrieval
        var shuffledAnswers = answers
        
        // Create label-switch pairs dynamically
        for (index, answer) in shuffledAnswers.enumerated() {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .center
            horizontalStack.distribution = .fill
            horizontalStack.spacing = 12
            
            let label = UILabel()
            label.text = answer.text
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.numberOfLines = 0
            label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.16, alpha: 1.0)
            
            let switchControl = UISwitch()
            switchControl.tag = index
            switchControl.isOn = false
            switchControl.onTintColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
            
            horizontalStack.addArrangedSubview(label)
            horizontalStack.addArrangedSubview(switchControl)
            
            multipleStackView.addArrangedSubview(horizontalStack)
        }
        
        // Add submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Answer", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
        submitButton.layer.cornerRadius = 8
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        submitButton.addTarget(self, action: #selector(multipleAnswerButtonPressed), for: .touchUpInside)
        
        multipleStackView.addArrangedSubview(submitButton)
    }
    
    // MARK: - Ranged Answer Update (Dynamic - Stretch Goal #3)
    func updateRangedStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        
        // Clear existing content
        rangedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create horizontal stack for labels
        let labelStack = UIStackView()
        labelStack.axis = .horizontal
        labelStack.distribution = .equalSpacing
        
        let firstLabel = UILabel()
        firstLabel.text = answers.first?.text ?? ""
        firstLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        firstLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        
        let lastLabel = UILabel()
        lastLabel.text = answers.last?.text ?? ""
        lastLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lastLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        
        labelStack.addArrangedSubview(firstLabel)
        labelStack.addArrangedSubview(lastLabel)
        
        // Create slider
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = Float(answers.count - 1)
        slider.value = 0
        slider.isContinuous = true
        slider.tintColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
        
        // Create submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Answer", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.95, alpha: 1.0)
        submitButton.layer.cornerRadius = 8
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        submitButton.addTarget(self, action: #selector(rangedAnswerButtonPressed), for: .touchUpInside)
        
        rangedStackView.addArrangedSubview(labelStack)
        rangedStackView.addArrangedSubview(slider)
        rangedStackView.addArrangedSubview(submitButton)
    }
    
    // MARK: - Actions
    @objc func singleAnswerButtonPressed(_ sender: UIButton) {
        let answer = currentShuffledAnswers[sender.tag]
        answersChosen.append(answer)
        nextQuestion()
    }
    
    @objc func multipleAnswerButtonPressed() {
        // Find all enabled switches (skip the last view which is the submit button)
        let stackViews = multipleStackView.arrangedSubviews.dropLast() // Remove submit button from iteration
        
        for view in stackViews {
            if let horizontalStack = view as? UIStackView,
               let switchControl = horizontalStack.arrangedSubviews.last as? UISwitch,
               switchControl.isOn {
                // Use the switch's tag to get the correct answer from shuffled array
                answersChosen.append(currentShuffledAnswers[switchControl.tag])
            }
        }
        
        nextQuestion()
    }
    
    @objc func rangedAnswerButtonPressed() {
        // Find the slider
        if let slider = rangedStackView.arrangedSubviews.compactMap({ $0 as? UISlider }).first {
            let index = Int(round(slider.value))
            answersChosen.append(currentShuffledAnswers[index])
        }
        
        nextQuestion()
    }
    
    // MARK: - Navigation
    func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < questions.count {
            stopQuestionTimer()
            startQuestionTimer()
            updateUI()
        } else {
            stopQuestionTimer()
            performSegue(withIdentifier: "Results", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Results",
           let resultsVC = segue.destination as? ResultsViewController {
            resultsVC.responses = answersChosen
            resultsVC.quizTitle = quiz?.title ?? "Quiz"
        }
    }
}
