import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.updatedAt, order: .reverse) private var entries: [JournalEntry]
    @State private var presentedEntry: JournalEntry?
    @State private var isAddingEntry = false

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(entries) { entry in
                            Button {
                                presentedEntry = entry
                            } label: {
                                JournalRow(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 7, leading: 20, bottom: 7, trailing: 20))
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.journalBackground.ignoresSafeArea())
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New journal entry")
                }
            }
            .sheet(isPresented: $isAddingEntry) {
                JournalEditorView()
            }
            .sheet(item: $presentedEntry) { entry in
                JournalEditorView(entry: entry)
            }
        }
        .tint(.journalGreen)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your journal is waiting", systemImage: "book.closed")
        } description: {
            Text("Make space for what’s on your mind.")
        } actions: {
            Button("Write your first entry") {
                isAddingEntry = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

private struct JournalRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.title.isEmpty ? "Untitled entry" : entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer()
                Text(entry.updatedAt, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(entry.body.isEmpty ? "No words yet" : entry.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

private extension Color {
    static let journalBackground = Color(uiColor: .systemGroupedBackground)
    static let journalGreen = Color(red: 0.12, green: 0.40, blue: 0.32)
}

#Preview {
    JournalListView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
