import SwiftUI
import SwiftData

struct JournalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let entry: JournalEntry?
    @State private var title: String
    @State private var bodyText: String

    init(entry: JournalEntry? = nil) {
        self.entry = entry
        _title = State(initialValue: entry?.title ?? "")
        _bodyText = State(initialValue: entry?.body ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day().year())
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 22)

                TextField("Give today a title", text: $title, axis: .vertical)
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .lineLimit(1...2)
                    .padding(.bottom, 18)

                TextEditor(text: $bodyText)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(7)
                    .scrollContentBackground(.hidden)
                    .overlay(alignment: .topLeading) {
                        if bodyText.isEmpty {
                            Text("Start writing…")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                                  bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .interactiveDismissDisabled(hasChanges)
        }
        .presentationDetents([.large])
    }

    private var hasChanges: Bool {
        title != (entry?.title ?? "") || bodyText != (entry?.body ?? "")
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)

        if let entry {
            entry.title = cleanTitle
            entry.body = cleanBody
            entry.updatedAt = .now
        } else {
            modelContext.insert(JournalEntry(title: cleanTitle, body: cleanBody))
        }

        try? modelContext.save()
        dismiss()
    }
}
