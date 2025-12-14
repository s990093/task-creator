import SwiftUI

struct TaskSuggestionCard: View {
    @Binding var task: SuggestedTask
    
    var body: some View {
        HStack {
            if task.isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "34C759"))
            } else {
                Button {
                    task.isSelected.toggle()
                } label: {
                    Image(systemName: task.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isSelected ? Color(hex: "34C759") : .gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(task.isAdded ? .gray : .white)
                    
                    if task.isAdded {
                        Text("已新增")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "34C759"))
                            .cornerRadius(8)
                    }
                }
                
                HStack(spacing: 8) {
                    Label(task.category, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(priorityText(task.priority), systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(priorityColor(task.priority))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(task.isAdded ? Color(hex: "1C1C1E").opacity(0.5) : Color(hex: "1E293B"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(task.isSelected && !task.isAdded ? Color(hex: "34C759") : Color.clear, lineWidth: 1)
        )
        .opacity(task.isAdded ? 0.7 : 1.0)
    }
    
    private func priorityText(_ priority: String) -> String {
        switch priority.lowercased() {
        case "urgent": return "急"
        case "high": return "高"
        case "normal": return "普通"
        case "low": return "低"
        default: return "普通"
        }
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "urgent", "high": return .red
        case "normal": return .orange
        case "low": return .blue
        default: return .gray
        }
    }
}
