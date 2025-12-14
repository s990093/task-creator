import SwiftUI

struct GoalsSection: View {
    @ObservedObject var profileManager: UserProfileManager
    @State private var newGoal = ""
    @State private var showingGoalInput = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Goals List
            if !profileManager.profile.goals.isEmpty {
                ForEach(Array(profileManager.profile.goals.enumerated()), id: \.offset) { index, goal in
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(Color(hex: "10B981"))
                            .font(.caption)
                        
                        Text(goal)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            profileManager.profile.goals.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1E293B"))
                    .cornerRadius(12)
                }
            }
            
            // Add Goal Button
            Button {
                showingGoalInput = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("新增目標")
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "4F46E5"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "4F46E5").opacity(0.1))
                .cornerRadius(12)
            }
        }
        .alert("新增學習目標", isPresented: $showingGoalInput) {
            TextField("例如：提升程式能力", text: $newGoal)
            Button("取消", role: .cancel) {
                newGoal = ""
            }
            Button("新增") {
                if !newGoal.isEmpty {
                    profileManager.profile.goals.append(newGoal)
                    newGoal = ""
                }
            }
        }
    }
}
