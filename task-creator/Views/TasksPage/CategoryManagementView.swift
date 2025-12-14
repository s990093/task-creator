import SwiftUI

struct CategoryManagementView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0 // 0 = Categories, 1 = Task Types
    @State private var newItemName = ""
    @State private var selectedIcon = "book.fill"
    @State private var selectedColor = Color.purple
    
    // Available icons
    private let categoryIcons = ["book.fill", "function", "globe", "paintbrush.fill", "flask.fill", "atom", "leaf.fill", "heart.fill", "star.fill", "flag.fill"]
    private let typeIcons = ["briefcase.fill", "house.fill", "heart.fill", "star.fill", "flag.fill", "tag.fill", "bookmark.fill", "folder.fill"]
    
    // Available colors
    private let colors: [Color] = [
        Color(hex: "FF9F0A"), // Orange
        Color(hex: "007AFF"), // Blue
        Color(hex: "30D158"), // Green
        Color(hex: "FF453A"), // Red
        Color(hex: "BF5AF2"), // Purple
        Color(hex: "FFD60A"), // Yellow
        Color(hex: "64D2FF"), // Cyan
        Color(hex: "FF375F")  // Pink
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1C2833")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    HStack(spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 0
                            }
                        } label: {
                            Text("管理類別")
                                .font(.subheadline)
                                .fontWeight(selectedTab == 0 ? .semibold : .regular)
                                .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == 0 ? Color(hex: "3D4A5C") : Color.clear)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 1
                            }
                        } label: {
                            Text("管理類型")
                                .font(.subheadline)
                                .fontWeight(selectedTab == 1 ? .semibold : .regular)
                                .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == 1 ? Color(hex: "3D4A5C") : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                    .padding(4)
                    .background(Color(hex: "2C3544"))
                    .cornerRadius(10)
                    .padding()
                    
                    ScrollView {
                        if selectedTab == 0 {
                            categoriesGrid
                        } else {
                            typesGrid
                        }
                    }
                    
                    // Add new item section
                    VStack(spacing: 12) {
                        Text(selectedTab == 0 ? "新增自定義類別" : "新增自定義類型")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            TextField("新增類別名稱...", text: $newItemName)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "2C3544"))
                                .cornerRadius(12)
                            
                            Button {
                                addNewItem()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: "BF5AF2"))
                                    .cornerRadius(12)
                            }
                            .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                        }
                        
                        Text("提示：點擊上方選單的「類別」或「類型」可直接切換管理畫面。")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(hex: "0F1419"))
                }
            }
            .navigationTitle(selectedTab == 0 ? "管理類別" : "管理類型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // Categories Grid
    private var categoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
            ForEach(viewModel.categories) { category in
                CategoryCardView(
                    icon: category.icon,
                    name: category.name,
                    color: category.color,
                    isSystem: category.isSystem
                ) {
                    if !category.isSystem {
                        viewModel.deleteCategory(category)
                    }
                }
            }
        }
        .padding()
    }
    
    // Types Grid
    private var typesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
            ForEach(viewModel.taskTypes) { type in
                TypeCardView(
                    icon: type.icon,
                    name: type.name,
                    isSystem: type.isSystem
                ) {
                    if !type.isSystem {
                        viewModel.deleteTaskType(type)
                    }
                }
            }
        }
        .padding()
    }
    
    private func addNewItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        if selectedTab == 0 {
            viewModel.addCategory(
                name: trimmedName,
                icon: categoryIcons.randomElement() ?? "folder.fill",
                colorHex: selectedColor.toHex() ?? "#BF5AF2"
            )
        } else {
            viewModel.addTaskType(
                name: trimmedName,
                icon: typeIcons.randomElement() ?? "tag.fill"
            )
        }
        
        newItemName = ""
    }
}


// MARK: - Category Card View
struct CategoryCardView: View {
    let icon: String
    let name: String
    let color: Color
    let isSystem: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            if !isSystem {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color(hex: "2C3544"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Type Card View
struct TypeCardView: View {
    let icon: String
    let name: String
    let isSystem: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            if !isSystem {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color(hex: "2C3544"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// Helper extension to convert Color to Hex
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

#Preview {
    CategoryManagementView()
        .environmentObject(TaskViewModel())
}
