
//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Suldana Afrah on 7/10/25.
//

import Foundation

// MARK: - API Response Models
struct TriviaAPIResponse: Codable {
    let response_code: Int
    let results: [TriviaAPIResult]
}

struct TriviaAPIResult: Codable {
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

class TriviaQuestionService {
    
    static let shared = TriviaQuestionService()
    
    private init() {}
    
    func fetchTriviaQuestions(completion: @escaping (Result<[TriviaQuestion], Error>) -> Void) {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=5") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(TriviaAPIResponse.self, from: data)
                let triviaQuestions = apiResponse.results.map { result in
                    TriviaQuestion(
                        category: result.category.htmlDecoded,
                        question: result.question.htmlDecoded,
                        correctAnswer: result.correct_answer.htmlDecoded,
                        incorrectAnswers: result.incorrect_answers.map { $0.htmlDecoded }
                    )
                }
                completion(.success(triviaQuestions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - String Extension for HTML Decoding
extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string
    }
}
