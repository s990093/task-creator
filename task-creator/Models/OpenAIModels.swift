import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: MessageContent
}

struct MessageContent: Codable {
    let role: String
    let content: String
}
