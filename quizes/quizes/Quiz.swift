//
//  Question.swift
//  MovieGenreQuiz
//
//  Created for IT8108 Re-Assessment
//

import Foundation

// MARK: - Question Model
struct Question {
    var text: String
    var type: ResponseType
    var answers: [Answer]
}

// MARK: - Response Type Enum
enum ResponseType {
    case single, multiple, ranged
}

// MARK: - Answer Model
struct Answer {
    var text: String
    var type: MovieGenre
}

// MARK: - Movie Genre Enum
enum MovieGenre: Character {
    case action = "🎬"
    case romance = "💕"
    case comedy = "😂"
    case horror = "👻"
    
    // Context-aware definitions based on quiz title
    func definition(for quizTitle: String) -> String {
        if quizTitle.contains("Career") {
            return careerDefinition
        } else if quizTitle.contains("Food") {
            return foodDefinition
        } else {
            return movieDefinition
        }
    }
    
    func displayName(for quizTitle: String) -> String {
        if quizTitle.contains("Career") {
            return careerName
        } else if quizTitle.contains("Food") {
            return foodName
        } else {
            return movieName
        }
    }
    
    // Movie Genre definitions
    private var movieDefinition: String {
        switch self {
        case .action:
            return "You are bold and adventurous! You love excitement, thrills, and high-energy experiences. You're always ready for the next big challenge."
        case .romance:
            return "You are warm and compassionate! You value deep connections, emotional experiences, and meaningful relationships with others."
        case .comedy:
            return "You are lighthearted and fun! You bring joy to those around you, love to laugh, and don't take life too seriously."
        case .horror:
            return "You are mysterious and daring! You're drawn to the unknown, enjoy thrills, and aren't afraid of the dark side of life."
        }
    }
    
    private var movieName: String {
        switch self {
        case .action: return "Action"
        case .romance: return "Romance"
        case .comedy: return "Comedy"
        case .horror: return "Horror"
        }
    }
    
    // Career definitions
    private var careerDefinition: String {
        switch self {
        case .action:
            return "You're a natural ENTREPRENEUR! You thrive in fast-paced environments, love taking risks, and excel at building things from the ground up. Perfect careers: CEO, Startup Founder, Business Owner, Sales Executive."
        case .romance:
            return "You're a born CAREGIVER! You find fulfillment in helping others and making a positive impact on people's lives. Perfect careers: Teacher, Nurse, Counselor, Social Worker, Therapist."
        case .comedy:
            return "You're a true CREATIVE! You express yourself through art, innovation, and imagination. You bring fresh ideas to everything you do. Perfect careers: Designer, Artist, Content Creator, Marketer, Entertainer."
        case .horror:
            return "You're a dedicated ANALYST! You love solving complex problems through research, data, and logical thinking. Perfect careers: Scientist, Data Analyst, Researcher, Engineer, Detective."
        }
    }
    
    private var careerName: String {
        switch self {
        case .action: return "Entrepreneur 💼"
        case .romance: return "Caregiver ❤️"
        case .comedy: return "Creative 🎨"
        case .horror: return "Analyst 🔬"
        }
    }
    
    // Food Personality definitions
    private var foodDefinition: String {
        switch self {
        case .action:
            return "You're an ADVENTUROUS EATER! You love trying exotic flavors, spicy challenges, and unique food experiences. You're always seeking the next culinary thrill and aren't afraid to try anything once!"
        case .romance:
            return "You're a GOURMET FOODIE! You appreciate fine dining, complex flavors, and culinary artistry. Wine pairings, sophisticated ingredients, and elegant presentations make your heart sing."
        case .comedy:
            return "You're a COMFORT FOOD LOVER! You find joy in classic, familiar favorites that bring warmth and happiness. Pizza, burgers, mac & cheese - the cozier the better!"
        case .horror:
            return "You're a HEALTH ENTHUSIAST! You prioritize fresh, nutritious ingredients and clean eating. Organic salads, smoothie bowls, and wholesome meals fuel your healthy lifestyle."
        }
    }
    
    private var foodName: String {
        switch self {
        case .action: return "Adventurous Eater 🌶️"
        case .romance: return "Gourmet Foodie 🍷"
        case .comedy: return "Comfort Food Lover 🍕"
        case .horror: return "Health Enthusiast 🥗"
        }
    }
}

// MARK: - Quiz Model
struct Quiz {
    var title: String
    var questions: [Question]
}

// MARK: - Quiz Result Model
struct QuizResult: Codable {
    var quizTitle: String
    var result: String
    var resultDefinition: String
    var date: Date
    var emoji: String
}

// MARK: - Sample Quizzes
extension Quiz {
    static let movieGenreQuiz = Quiz(
        title: "What Movie Genre Are You?",
        questions: [
            Question(
                text: "What's your ideal Friday night?",
                type: .single,
                answers: [
                    Answer(text: "Extreme sports or adventure", type: .action),
                    Answer(text: "Romantic dinner date", type: .romance),
                    Answer(text: "Comedy show with friends", type: .comedy),
                    Answer(text: "Watching scary movies", type: .horror)
                ]
            ),
            Question(
                text: "Which activities do you enjoy? (Select all that apply)",
                type: .multiple,
                answers: [
                    Answer(text: "Rock climbing", type: .action),
                    Answer(text: "Writing poetry", type: .romance),
                    Answer(text: "Stand-up comedy", type: .comedy),
                    Answer(text: "Escape rooms", type: .horror)
                ]
            ),
            Question(
                text: "How much do you enjoy adrenaline rushes?",
                type: .ranged,
                answers: [
                    Answer(text: "Not at all", type: .romance),
                    Answer(text: "A little bit", type: .comedy),
                    Answer(text: "Quite a bit", type: .horror),
                    Answer(text: "Absolutely love them!", type: .action)
                ]
            ),
            Question(
                text: "Pick your vacation destination:",
                type: .single,
                answers: [
                    Answer(text: "Skydiving in New Zealand", type: .action),
                    Answer(text: "Paris, the city of love", type: .romance),
                    Answer(text: "Comedy festival in Edinburgh", type: .comedy),
                    Answer(text: "Haunted castle tour", type: .horror)
                ]
            )
        ]
    )
    
    static let careerQuiz = Quiz(
        title: "What's Your Dream Career?",
        questions: [
            Question(
                text: "What motivates you most?",
                type: .single,
                answers: [
                    Answer(text: "Challenges and competition", type: .action),
                    Answer(text: "Helping others succeed", type: .romance),
                    Answer(text: "Creativity and innovation", type: .comedy),
                    Answer(text: "Solving complex problems", type: .horror)
                ]
            ),
            Question(
                text: "Which work environments appeal to you? (Select all that apply)",
                type: .multiple,
                answers: [
                    Answer(text: "Fast-paced startup office", type: .action),
                    Answer(text: "Community center or hospital", type: .romance),
                    Answer(text: "Creative design studio", type: .comedy),
                    Answer(text: "Research laboratory", type: .horror)
                ]
            ),
            Question(
                text: "How do you handle workplace stress?",
                type: .ranged,
                answers: [
                    Answer(text: "Talk it through with team", type: .romance),
                    Answer(text: "Express through creativity", type: .comedy),
                    Answer(text: "Analyze data and strategize", type: .horror),
                    Answer(text: "Take bold decisive action", type: .action)
                ]
            ),
            Question(
                text: "What's your ideal work achievement?",
                type: .single,
                answers: [
                    Answer(text: "Building a successful business", type: .action),
                    Answer(text: "Changing someone's life for better", type: .romance),
                    Answer(text: "Creating award-winning work", type: .comedy),
                    Answer(text: "Making a scientific breakthrough", type: .horror)
                ]
            )
        ]
    )
    
    static let foodQuiz = Quiz(
        title: "What's Your Food Personality?",
        questions: [
            Question(
                text: "What's your go-to meal?",
                type: .single,
                answers: [
                    Answer(text: "Spicy Thai curry", type: .action),
                    Answer(text: "Fine dining tasting menu", type: .romance),
                    Answer(text: "Classic pepperoni pizza", type: .comedy),
                    Answer(text: "Fresh organic salad", type: .horror)
                ]
            ),
            Question(
                text: "Which dining experiences excite you? (Select all that apply)",
                type: .multiple,
                answers: [
                    Answer(text: "Exotic street food adventures", type: .action),
                    Answer(text: "Michelin-starred restaurants", type: .romance),
                    Answer(text: "Cozy comfort food diners", type: .comedy),
                    Answer(text: "Farm-to-table organic cafes", type: .horror)
                ]
            ),
            Question(
                text: "How adventurous is your palate?",
                type: .ranged,
                answers: [
                    Answer(text: "Refined and elegant", type: .romance),
                    Answer(text: "Familiar and comforting", type: .comedy),
                    Answer(text: "Clean and nutritious", type: .horror),
                    Answer(text: "Daring and exotic", type: .action)
                ]
            ),
            Question(
                text: "Your dream food destination?",
                type: .single,
                answers: [
                    Answer(text: "Street food tour in Bangkok", type: .action),
                    Answer(text: "Wine tasting in French vineyard", type: .romance),
                    Answer(text: "Pizza and pasta in Italy", type: .comedy),
                    Answer(text: "Organic farm retreat in California", type: .horror)
                ]
            )
        ]
    )
    
    static let allQuizzes = [movieGenreQuiz, careerQuiz, foodQuiz]
}
