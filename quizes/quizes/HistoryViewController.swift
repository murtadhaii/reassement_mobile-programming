//
//  QuizHistoryViewController.swift
//  MovieGenreQuiz
//
//  Created for IT8108 Re-Assessment
//  Stretch Goal #4: Display history of completed quizzes
//

import UIKit

class QuizHistoryViewController: UITableViewController {
    
    // MARK: - Properties
    var quizHistory: [QuizResult] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Quiz History"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        loadHistory()
        
        // Add clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearHistory)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistory()
    }
    
    // MARK: - Data Loading
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "quizHistory"),
           let history = try? JSONDecoder().decode([QuizResult].self, from: data) {
            quizHistory = history.reversed() // Show most recent first
        }
        tableView.reloadData()
    }
    
    @objc func clearHistory() {
        let alert = UIAlertController(
            title: "Clear History",
            message: "Are you sure you want to delete all quiz history?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            UserDefaults.standard.removeObject(forKey: "quizHistory")
            self?.quizHistory = []
            self?.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if quizHistory.isEmpty {
            // Show empty state
            let emptyLabel = UILabel()
            emptyLabel.text = "No quiz history yet!\nComplete a quiz to see results here."
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.textColor = .gray
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = emptyLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return quizHistory.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        let result = quizHistory[indexPath.row]
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        content.text = "\(result.emoji) \(result.quizTitle)"
        content.secondaryText = "Result: \(result.result) - \(formatDate(result.date))"
        content.secondaryTextProperties.color = .gray
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = quizHistory[indexPath.row]
        
        let alert = UIAlertController(
            title: "\(result.emoji) \(result.result)",
            message: result.resultDefinition,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove from array
            quizHistory.remove(at: indexPath.row)
            
            // Save updated history
            let reversedHistory = quizHistory.reversed()
            if let encoded = try? JSONEncoder().encode(Array(reversedHistory)) {
                UserDefaults.standard.set(encoded, forKey: "quizHistory")
            }
            
            // Update table
            tableView.deleteRows(at: [indexPath], with: .fade)
            loadHistory() // Reload to show empty state if needed
        }
    }
    
    // MARK: - Helper Methods
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
