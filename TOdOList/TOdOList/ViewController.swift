// ToDoTableViewController.swift
import UIKit
import UserNotifications

class ToDoTableViewController: UITableViewController {

    // MARK: - Data
    var toDos: [ToDo] = []
    var filteredToDos: [ToDo] = []
    var selectedCategory: ToDoCategory? = nil

    // MARK: - UI
    private let searchController = UISearchController(searchResultsController: nil)
    private var categoryControl: UISegmentedControl!

    // MARK: - Computed
    private var isSearching: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    private var displayedToDos: [ToDo] {
        if isSearching { return filteredToDos }
        guard let cat = selectedCategory else { return toDos }
        return toDos.filter { $0.category == cat }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        toDos = ToDo.loadToDos() ?? ToDo.loadSampleToDos()
        setupAppearance()
        setupNavBar()
        setupSearch()
        setupCategoryBar()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    // MARK: - Appearance
    private func setupAppearance() {
        let bg = UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
        view.backgroundColor         = bg
        tableView.backgroundColor    = bg
        tableView.separatorStyle     = .none
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.contentInset       = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        tableView.register(ToDoCell.self, forCellReuseIdentifier: "ToDoCell")
    }

    private func setupNavBar() {
        title = "My Tasks"
        navigationController?.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor          = UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
        appearance.titleTextAttributes      = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 20)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"), style: .plain,
            target: self, action: #selector(addTapped))
    }

    private func setupSearch() {
        searchController.searchResultsUpdater                 = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder                = "Search tasks…"
        searchController.searchBar.tintColor                  = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        navigationItem.searchController            = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupCategoryBar() {
        let items = ["All"] + ToDoCategory.allCases.map { $0.rawValue }
        categoryControl = UISegmentedControl(items: items)
        categoryControl.selectedSegmentIndex     = 0
        categoryControl.backgroundColor          = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)
        categoryControl.selectedSegmentTintColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        categoryControl.setTitleTextAttributes([.foregroundColor: UIColor(white: 0.7, alpha: 1), .font: UIFont.systemFont(ofSize: 11)], for: .normal)
        categoryControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 11)], for: .selected)
        categoryControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
        header.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)
        categoryControl.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(categoryControl)
        NSLayoutConstraint.activate([
            categoryControl.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            categoryControl.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12),
            categoryControl.centerYAnchor.constraint(equalTo: header.centerYAnchor),
        ])
        tableView.tableHeaderView = header
    }

    // MARK: - Actions
    @objc private func addTapped() { presentDetail(existing: nil) }

    @objc private func categoryChanged() {
        selectedCategory = categoryControl.selectedSegmentIndex == 0
            ? nil : ToDoCategory.allCases[categoryControl.selectedSegmentIndex - 1]
        tableView.reloadData()
    }

    // MARK: - Present Detail (modal)
    private func presentDetail(existing: ToDo?) {
        let detail = ToDoDetailTableViewController(style: .grouped)
        detail.toDo = existing
        detail.onSave = { [weak self] savedToDo in
            guard let self = self else { return }
            if let i = self.toDos.firstIndex(of: savedToDo) {
                self.toDos[i].removeNotification()
                self.toDos[i] = savedToDo
                savedToDo.scheduleNotification()
            } else {
                self.toDos.append(savedToDo)
                savedToDo.scheduleNotification()
            }
            ToDo.saveToDos(self.toDos)
            self.tableView.reloadData()
        }
        let nav = UINavigationController(rootViewController: detail)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    // MARK: - Share
    private func share(_ toDo: ToDo) {
        var text = "📋 \(toDo.title)\n📅 \(toDo.formattedDueDate)\n🏷 \(toDo.category.rawValue)\n✅ \(toDo.isComplete ? "Complete" : "Pending")"
        if let n = toDo.notes, !n.isEmpty { text += "\n📝 \(n)" }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let pop = vc.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(vc, animated: true)
    }
}

// MARK: - DataSource
extension ToDoTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = displayedToDos.count
        tableView.backgroundView = count == 0 ? emptyLabel() : nil
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoCell
        cell.configure(with: displayedToDos[indexPath.row])
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let t = displayedToDos[indexPath.row]
        t.removeNotification()
        if let i = toDos.firstIndex(of: t) { toDos.remove(at: i) }
        tableView.deleteRows(at: [indexPath], with: .fade)
        ToDo.saveToDos(toDos)
    }

    private func emptyLabel() -> UILabel {
        let l = UILabel()
        l.text = "No tasks yet.\nTap + to get started."
        l.numberOfLines = 2; l.textAlignment = .center
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = UIColor(white: 0.45, alpha: 1)
        return l
    }
}

// MARK: - UITableViewDelegate
extension ToDoTableViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toDo = displayedToDos[indexPath.row]

        let del = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, done in
            guard let self = self else { return done(false) }
            toDo.removeNotification()
            if let i = self.toDos.firstIndex(of: toDo) { self.toDos.remove(at: i) }
            tableView.deleteRows(at: [indexPath], with: .fade)
            ToDo.saveToDos(self.toDos)
            done(true)
        }
        del.image = UIImage(systemName: "trash.fill")
        del.backgroundColor = UIColor(red: 1, green: 0.27, blue: 0.27, alpha: 1)

        let shareAct = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
            self?.share(toDo); done(true)
        }
        shareAct.image = UIImage(systemName: "square.and.arrow.up")
        shareAct.backgroundColor = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)

        return UISwipeActionsConfiguration(actions: [del, shareAct])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentDetail(existing: displayedToDos[indexPath.row])
    }
}

// MARK: - Cell Delegate
extension ToDoTableViewController: ToDoCellDelegate {
    func checkmarkTapped(sender: ToDoCell) {
        guard let ip = tableView.indexPath(for: sender) else { return }
        let t = displayedToDos[ip.row]
        if let i = toDos.firstIndex(of: t) {
            toDos[i].isComplete.toggle()
            toDos[i].isComplete ? toDos[i].removeNotification() : toDos[i].scheduleNotification()
            tableView.reloadRows(at: [ip], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
}

// MARK: - Search
extension ToDoTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let q = (searchController.searchBar.text ?? "").lowercased()
        filteredToDos = toDos.filter {
            $0.title.lowercased().contains(q) ||
            ($0.notes?.lowercased().contains(q) ?? false) ||
            $0.category.rawValue.lowercased().contains(q)
        }
        tableView.reloadData()
    }
}
