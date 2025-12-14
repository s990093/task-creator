import SwiftUI

struct TaskTypeSuggestionCard: View {
    @Binding var taskType: SuggestedTaskType
    
    var body: some View {
        HStack {
            if taskType.isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "34C759"))
            } else {
                Button {
                    taskType.isSelected.toggle()
                } label: {
                    Image(systemName: taskType.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(taskType.isSelected ? Color(hex: "34C759") : .gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(taskType.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(taskType.isAdded ? .gray : .white)
                    
                    if taskType.isAdded {
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
                    Image(systemName: taskType.icon)
                        .font(.caption)
                        .foregroundColor(Color(hex: "A78BFA"))
                    
                    Text("任務類型")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(taskType.isAdded ? Color(hex: "1C1C1E").opacity(0.5) : Color(hex: "1E293B"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(taskType.isSelected && !taskType.isAdded ? Color(hex: "34C759") : Color.clear, lineWidth: 1)
        )
        .opacity(taskType.isAdded ? 0.7 : 1.0)
    }
}
