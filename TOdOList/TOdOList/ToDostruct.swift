// ToDoCell.swift
import UIKit

protocol ToDoCellDelegate: AnyObject {
    func checkmarkTapped(sender: ToDoCell)
}

class ToDoCell: UITableViewCell {

    let cardView         = UIView()
    let isCompleteButton = UIButton(type: .custom)
    let titleLabel       = UILabel()
    let dueDateLabel     = UILabel()
    let categoryBadge    = UILabel()
    weak var delegate: ToDoCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
        selectionStyle  = .none
        contentView.backgroundColor = .clear

        cardView.backgroundColor    = UIColor(red: 0.14, green: 0.14, blue: 0.20, alpha: 1)
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor  = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.20
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        isCompleteButton.layer.cornerRadius  = 14
        isCompleteButton.layer.masksToBounds = true
        isCompleteButton.layer.borderWidth   = 2
        isCompleteButton.layer.borderColor   = UIColor(white: 0.45, alpha: 1).cgColor
        isCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        isCompleteButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        cardView.addSubview(isCompleteButton)

        titleLabel.font          = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor     = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        dueDateLabel.font      = .systemFont(ofSize: 12)
        dueDateLabel.textColor = UIColor(white: 0.65, alpha: 1)
        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dueDateLabel)

        categoryBadge.font                = .systemFont(ofSize: 10, weight: .bold)
        categoryBadge.textColor           = .white
        categoryBadge.textAlignment       = .center
        categoryBadge.layer.cornerRadius  = 8
        categoryBadge.layer.masksToBounds = true
        categoryBadge.backgroundColor     = UIColor(red: 0.42, green: 0.39, blue: 1, alpha: 1)
        categoryBadge.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(categoryBadge)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            isCompleteButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            isCompleteButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            isCompleteButton.widthAnchor.constraint(equalToConstant: 28),
            isCompleteButton.heightAnchor.constraint(equalToConstant: 28),

            categoryBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            categoryBadge.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            categoryBadge.widthAnchor.constraint(equalToConstant: 74),
            categoryBadge.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: isCompleteButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: categoryBadge.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            dueDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dueDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dueDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dueDateLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10),
        ])
    }

    func configure(with toDo: ToDo) {
        if toDo.isComplete {
            titleLabel.attributedText = NSAttributedString(string: toDo.title, attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor(white: 0.5, alpha: 1)
            ])
        } else {
            titleLabel.attributedText = nil
            titleLabel.text      = toDo.title
            titleLabel.textColor = .white
        }

        if toDo.isOverdue {
            dueDateLabel.text      = "⚠️ Overdue · \(toDo.formattedDueDate)"
            dueDateLabel.textColor = UIColor(red: 1, green: 0.36, blue: 0.36, alpha: 1)
        } else if toDo.isDueSoon {
            dueDateLabel.text      = "🔔 Due soon · \(toDo.formattedDueDate)"
            dueDateLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        } else {
            dueDateLabel.text      = "📅 \(toDo.formattedDueDate)"
            dueDateLabel.textColor = UIColor(white: 0.65, alpha: 1)
        }

        categoryBadge.text            = " \(toDo.category.rawValue) "
        categoryBadge.backgroundColor = categoryColor(for: toDo.category)

        let accent = UIColor(red: 0.42, green: 0.39, blue: 1.0, alpha: 1)
        if toDo.isComplete {
            isCompleteButton.backgroundColor   = accent
            isCompleteButton.layer.borderColor = accent.cgColor
            isCompleteButton.setImage(UIImage(systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
            isCompleteButton.tintColor = .white
        } else {
            isCompleteButton.backgroundColor   = .clear
            isCompleteButton.layer.borderColor = UIColor(white: 0.45, alpha: 1).cgColor
            isCompleteButton.setImage(nil, for: .normal)
        }
        cardView.alpha = toDo.isComplete ? 0.6 : 1.0
    }

    private func categoryColor(for cat: ToDoCategory) -> UIColor {
        switch cat {
        case .personal:  return UIColor(red: 0.42, green: 0.39, blue: 1.00, alpha: 1)
        case .work:      return UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 1)
        case .shopping:  return UIColor(red: 0.95, green: 0.78, blue: 0.20, alpha: 1)
        case .health:    return UIColor(red: 0.42, green: 0.80, blue: 0.47, alpha: 1)
        case .completed: return UIColor(red: 0.30, green: 0.59, blue: 1.00, alpha: 1)
        }
    }

    @objc private func completeTapped() { delegate?.checkmarkTapped(sender: self) }
}
