import SwiftUI

struct ImportantDatesSectionView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.yellow)
                    Text("重要日程")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    // Action for View All, maybe expand or navigate
                }) {
                    Text("查看全部")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Horizontal List
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.importantDates) { date in
                        DateCardView(date: date)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteImportantDate(id: date.id)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                    }
                    
                    // Add Button Card
                    Button(action: {
                        showAddSheet = true
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 60, height: 160)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(Color.white.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDateSheet()
        }
    }
}

#Preview {
    ImportantDatesSectionView()
        .environmentObject(TaskViewModel())
        .background(Color.black)
}
