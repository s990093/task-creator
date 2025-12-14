import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.role == .assistant {
                // AI Avatar
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "4F46E5")) // Indigo
                    .clipShape(Circle())
            } else {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.role == .assistant {
                    highlightedText(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(hex: "1E293B")) // Dark Slate for AI
                        .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                } else {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(hex: "7C3AED")) // Purple for user
                        .cornerRadius(20, corners: [.topLeft, .topRight, .bottomLeft])
                }
            }
            
            if message.role == .user {
                // User Avatar
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "7C3AED")) // Purple
                    .clipShape(Circle())
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Keyword Highlighting
    
    private func highlightedText(_ content: String) -> some View {
        let keywords = ["目前身份", "學習目標", "身份", "目標"]
        var attributedString = AttributedString(content)
        
        // Highlight keywords in purple
        for keyword in keywords {
            var searchRange = attributedString.startIndex..<attributedString.endIndex
            while let range = attributedString[searchRange].range(of: keyword) {
                attributedString[range].foregroundColor = Color(hex: "A78BFA") // Purple
                attributedString[range].font = .body.bold()
                
                // Move search range forward
                if range.upperBound < attributedString.endIndex {
                    searchRange = range.upperBound..<attributedString.endIndex
                } else {
                    break
                }
            }
        }
        
        return Text(attributedString)
            .font(.body)
            .foregroundColor(.white)
    }
}

