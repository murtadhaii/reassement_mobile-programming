// ToDoDetailTableViewController.swift
import UIKit
import UserNotifications

class ToDoDetailTableViewController: UITableViewController {

    // MARK: - Public
    var toDo: ToDo?

    // MARK: - UI (built in viewDidLoad)
    private let titleTextField    = UITextField()
    private let isCompleteButton  = UIButton(type: .custom)
    private let dueDateLabel      = UILabel()
    private let dueDatePicker     = UIDatePicker()
    private let notesTextView     = UITextView()
    private let categorySegment   = UISegmentedControl(items: ToDoCategory.allCases.map { $0.rawValue })
    private let reminderSwitch    = UISwitch()
    private let reminderLabel     = UILabel()
    private var saveButton: UIBarButtonItem!

    private var isDatePickerHidden = true

    // Fixed index paths
    private let ipDateLabel  = IndexPath(row: 0, section: 1)
    private let ipDatePicker = IndexPath(row: 1, section: 1)
    private let ipNotes      = IndexPath(row: 0, section: 2)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupAppearance()
        setupCells()
        populate()
        updateSaveState()
    }

    // MARK: - Setup
    private func setupNavBar() {
        navigationItem.title = toDo == nil ? "New Task" : "Edit Task"

        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        saveButton    = UIBarButtonItem(title: "Save",   style: .done,  target: self, action: #selector(saveTapped))

        cancelBtn.tintColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        saveButton.tintColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)

        navigationItem.leftBarButtonItem  = cancelBtn
        navigationItem.rightBarButtonItem = saveButton

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor     = UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupAppearance() {
        let bg = UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
        view.backgroundColor          = bg
        tableView.backgroundColor     = bg
        tableView.separatorColor      = UIColor(white: 0.18, alpha: 1)
    }

    // Build all cell content programmatically
    private func setupCells() {
        // Title text field
        titleTextField.placeholder   = "Task title…"
        titleTextField.font          = .systemFont(ofSize: 17)
        titleTextField.textColor     = .white
        titleTextField.returnKeyType = .done
        titleTextField.autocapitalizationType = .sentences
        titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(titleReturn), for: .primaryActionTriggered)

        // Complete button
        isCompleteButton.layer.cornerRadius  = 14
        isCompleteButton.layer.masksToBounds = true
        isCompleteButton.layer.borderWidth   = 2
        isCompleteButton.layer.borderColor   = UIColor(white: 0.4, alpha: 1).cgColor
        isCompleteButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        // Date label
        dueDateLabel.font      = .systemFont(ofSize: 15)
        dueDateLabel.textColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        dueDateLabel.textAlignment = .right

        // Date picker
        dueDatePicker.datePickerMode      = .dateAndTime
        dueDatePicker.preferredDatePickerStyle = .wheels
        dueDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        // Notes
        notesTextView.font            = .systemFont(ofSize: 15)
        notesTextView.textColor       = UIColor(white: 0.8, alpha: 1)
        notesTextView.backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.15, alpha: 1)
        notesTextView.layer.cornerRadius  = 8
        notesTextView.layer.masksToBounds = true
        notesTextView.textContainerInset  = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)

        // Category
        let accent = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        categorySegment.backgroundColor          = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)
        categorySegment.selectedSegmentTintColor = accent
        categorySegment.setTitleTextAttributes([.foregroundColor: UIColor(white: 0.7, alpha: 1), .font: UIFont.systemFont(ofSize: 11)], for: .normal)
        categorySegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 11)], for: .selected)

        // Reminder
        reminderLabel.text      = "Notify at due date"
        reminderLabel.font      = .systemFont(ofSize: 16)
        reminderLabel.textColor = UIColor(white: 0.8, alpha: 1)
        reminderSwitch.onTintColor = accent
        reminderSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    private func populate() {
        let date = toDo?.dueDate ?? Date().addingTimeInterval(86400)
        dueDatePicker.date = date
        updateDateLabel(date)

        if let t = toDo {
            titleTextField.text = t.title
            notesTextView.text  = t.notes ?? ""
            reminderSwitch.isOn = t.hasReminder
            if let i = ToDoCategory.allCases.firstIndex(of: t.category) {
                categorySegment.selectedSegmentIndex = i
            }
            isCompleteButton.isSelected = t.isComplete
        }
        updateCompleteButton()
    }

    // MARK: - Helpers
    private func updateDateLabel(_ date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits).hour().minute())
    }

    private func updateSaveState() {
        saveButton.isEnabled = !(titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
    }

    private func updateCompleteButton() {
        let accent = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        if isCompleteButton.isSelected {
            isCompleteButton.backgroundColor   = accent
            isCompleteButton.layer.borderColor = accent.cgColor
            isCompleteButton.setImage(UIImage(systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
            isCompleteButton.tintColor = .white
        } else {
            isCompleteButton.backgroundColor   = .clear
            isCompleteButton.layer.borderColor = UIColor(white: 0.4, alpha: 1).cgColor
            isCompleteButton.setImage(nil, for: .normal)
        }
    }

    // MARK: - Actions
    @objc private func titleChanged()  { updateSaveState() }
    @objc private func titleReturn()   { titleTextField.resignFirstResponder() }
    @objc private func dateChanged()   { updateDateLabel(dueDatePicker.date) }
    @objc private func completeTapped() {
        isCompleteButton.isSelected.toggle()
        updateCompleteButton()
    }
    @objc private func switchChanged() {
        if reminderSwitch.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus != .authorized {
                        self?.reminderSwitch.isOn = false
                        let a = UIAlertController(title: "Notifications Off", message: "Enable in Settings to use reminders.", preferredStyle: .alert)
                        a.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(a, animated: true)
                    }
                }
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let title      = titleTextField.text ?? ""
        let isComplete = isCompleteButton.isSelected
        let dueDate    = dueDatePicker.date
        let notes      = notesTextView.text.isEmpty ? nil : notesTextView.text
        let catIdx     = categorySegment.selectedSegmentIndex
        let category   = catIdx < ToDoCategory.allCases.count ? ToDoCategory.allCases[catIdx] : .personal
        let reminder   = reminderSwitch.isOn

        if toDo != nil {
            toDo!.title       = title
            toDo!.isComplete  = isComplete
            toDo!.dueDate     = dueDate
            toDo!.notes       = notes
            toDo!.category    = category
            toDo!.hasReminder = reminder
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate,
                        notes: notes, category: category, hasReminder: reminder)
        }

        // Dismiss and notify the list controller
        dismiss(animated: true) { [weak self] in
            guard let self = self, let toDo = self.toDo else { return }
            self.onSave?(toDo)
        }
    }

    /// Callback set by the presenting controller
    var onSave: ((ToDo) -> Void)?
}

// MARK: - TableView DataSource / Delegate
extension ToDoDetailTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int { 5 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        [1, 2, 1, 1, 1][section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Basic Information", "Due Date", "Notes", "Category", "Reminder"][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor    = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)
        cell.selectionStyle     = .none
        cell.textLabel?.text    = nil

        switch indexPath {
        case IndexPath(row: 0, section: 0):
            // Complete button + title field side by side
            isCompleteButton.translatesAutoresizingMaskIntoConstraints = false
            titleTextField.translatesAutoresizingMaskIntoConstraints   = false
            cell.contentView.addSubview(isCompleteButton)
            cell.contentView.addSubview(titleTextField)
            NSLayoutConstraint.activate([
                isCompleteButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                isCompleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                isCompleteButton.widthAnchor.constraint(equalToConstant: 28),
                isCompleteButton.heightAnchor.constraint(equalToConstant: 28),
                titleTextField.leadingAnchor.constraint(equalTo: isCompleteButton.trailingAnchor, constant: 12),
                titleTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                titleTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])

        case IndexPath(row: 0, section: 1):
            // Due date row label
            let staticLabel = UILabel()
            staticLabel.text      = "Due Date"
            staticLabel.font      = .systemFont(ofSize: 16)
            staticLabel.textColor = UIColor(white: 0.8, alpha: 1)
            staticLabel.translatesAutoresizingMaskIntoConstraints = false
            dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(staticLabel)
            cell.contentView.addSubview(dueDateLabel)
            cell.selectionStyle = .default
            NSLayoutConstraint.activate([
                staticLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                staticLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                dueDateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                dueDateLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])

        case IndexPath(row: 1, section: 1):
            // Date picker row
            dueDatePicker.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(dueDatePicker)
            NSLayoutConstraint.activate([
                dueDatePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                dueDatePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                dueDatePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                dueDatePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            ])

        case IndexPath(row: 0, section: 2):
            // Notes
            notesTextView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(notesTextView)
            NSLayoutConstraint.activate([
                notesTextView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 12),
                notesTextView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
                notesTextView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                notesTextView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            ])

        case IndexPath(row: 0, section: 3):
            // Category
            categorySegment.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(categorySegment)
            NSLayoutConstraint.activate([
                categorySegment.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 12),
                categorySegment.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
                categorySegment.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])

        case IndexPath(row: 0, section: 4):
            // Reminder
            reminderLabel.translatesAutoresizingMaskIntoConstraints = false
            reminderSwitch.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(reminderLabel)
            cell.contentView.addSubview(reminderSwitch)
            NSLayoutConstraint.activate([
                reminderLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                reminderLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                reminderSwitch.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                reminderSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])

        default: break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == ipDatePicker { return isDatePickerHidden ? 0 : 216 }
        if indexPath == ipNotes      { return 150 }
        return 56
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == ipDateLabel {
            isDatePickerHidden.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = UIColor(white: 0.6, alpha: 1)
    }
}
