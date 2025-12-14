import SwiftUI

struct IdentitySection: View {
    @ObservedObject var profileManager: UserProfileManager
    @State private var newLanguage = ""
    @State private var showingLanguageInput = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Nickname
            VStack(alignment: .leading, spacing: 8) {
                Text("暱稱")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("例如：小賴", text: $profileManager.profile.nickname)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(hex: "1E293B"))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            
            // Timezone
            VStack(alignment: .leading, spacing: 8) {
                Text("時區")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Menu {
                    Button("Asia/Taipei (GMT+8)") {
                        profileManager.profile.timezone = "Asia/Taipei (GMT+8)"
                    }
                    Button("America/New_York (GMT-5)") {
                        profileManager.profile.timezone = "America/New_York (GMT-5)"
                    }
                    Button("Europe/London (GMT+0)") {
                        profileManager.profile.timezone = "Europe/London (GMT+0)"
                    }
                } label: {
                    HStack {
                        Text(profileManager.profile.timezone)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(hex: "1E293B"))
                    .cornerRadius(12)
                }
            }
            
            // Language Chips
            VStack(alignment: .leading, spacing: 8) {
                Text("語言偏好")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(profileManager.profile.languages, id: \.self) { language in
                            LanguageChip(
                                language: language,
                                isSelected: true,
                                onRemove: {
                                    profileManager.profile.languages.removeAll { $0 == language }
                                }
                            )
                        }
                        
                        Button {
                            showingLanguageInput = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("新增")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        }
                    }
                }
            }
        }
        .alert("新增語言", isPresented: $showingLanguageInput) {
            TextField("例如：English", text: $newLanguage)
            Button("取消", role: .cancel) {
                newLanguage = ""
            }
            Button("新增") {
                if !newLanguage.isEmpty {
                    profileManager.profile.languages.append(newLanguage)
                    newLanguage = ""
                }
            }
        }
    }
}

struct LanguageChip: View {
    let language: String
    let isSelected: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(language)
                .font(.subheadline)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
        }
        .foregroundColor(isSelected ? .white : .gray)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Color(hex: "4F46E5") : Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}
