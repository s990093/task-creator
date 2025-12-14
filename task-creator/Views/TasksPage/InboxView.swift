import SwiftUI
import UniformTypeIdentifiers

struct InboxView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isTargeted = false
    
    var inboxTasks: [Task] {
        viewModel.tasks.filter { $0.day == nil && !$0.completed }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("INBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1)
                
                Text("\(inboxTasks.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.orange)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(inboxTasks) { task in
                        TaskCardView(task: task)
                            .frame(width: 280)
                            .onDrag {
                                NSItemProvider(object: task.id as NSString)
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(height: 140) // Fixed height for Inbox row
            .background(isTargeted ? AppTheme.surface.opacity(0.5) : Color.black.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTargeted ? Color.brandBlue : Color.clear, lineWidth: 2)
            )
            .onDrop(of: [UTType.text], delegate: TaskDropDelegate(day: nil, viewModel: viewModel, isTargeted: $isTargeted))
        }
    }
}

struct TaskDropDelegate: DropDelegate {
    let day: Day?
    let viewModel: TaskViewModel
    @Binding var isTargeted: Bool
    
    func dropEntered(info: DropInfo) {
        withAnimation {
            isTargeted = true
        }
    }
    
    func dropExited(info: DropInfo) {
        withAnimation {
            isTargeted = false
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [UTType.text]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            if let data = data as? Data, let id = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    viewModel.moveTask(id: id, to: day)
                    withAnimation {
                        isTargeted = false
                    }
                }
            }
        }
        return true
    }
}
