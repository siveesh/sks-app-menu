import SwiftUI
import MenuCore

struct CategoryManagementView: View {
    @Bindable var model: CatalogModel
    @State private var name = ""
    @State private var selectedID: String?
    @State private var deleteID: String?

    private var selectedCustom: Bool { model.document.categories.contains { $0.id == selectedID } }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories").font(.title2).fontWeight(.semibold)
            Text("Built-in categories follow application metadata. Custom categories can be assigned in Manage Applications.")
                .foregroundStyle(.secondary).font(.callout)
            List(selection: $selectedID) {
                Section("Custom Categories") {
                    ForEach(model.document.categories.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }) { category in
                        Text(category.name).tag(category.id)
                    }
                    if model.document.categories.isEmpty { Text("No custom categories").foregroundStyle(.secondary) }
                }
                Section("Built-in Categories") {
                    ForEach(CategoryResolver.builtIn) { category in
                        HStack { Text(category.name); Spacer(); Image(systemName: "lock").foregroundStyle(.tertiary).accessibilityLabel("Built-in") }
                    }
                }
            }.frame(minHeight: 160)
            HStack {
                TextField("Category name", text: $name).onSubmit { create() }
                    .accessibilityLabel("Category name")
                Button("Create") { create() }.disabled(!model.canEdit || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            HStack {
                Button("Rename Selected") {
                    if let selectedID { model.renameCategory(id: selectedID, name: name) }
                }.disabled(!model.canEdit || !selectedCustom || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Delete Selected…", role: .destructive) { deleteID = selectedID }
                    .disabled(!model.canEdit || !selectedCustom)
                Spacer()
            }
            Text("Select a custom category to rename or delete it. Deleting restores its apps to Automatic.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(22).frame(minWidth: 430, minHeight: 380)
        .onChange(of: selectedID) { _, id in
            if let category = model.document.categories.first(where: { $0.id == id }) { name = category.name }
        }
        .confirmationDialog("Delete this custom category?", isPresented: Binding(get: { deleteID != nil }, set: { if !$0 { deleteID = nil } })) {
            Button("Delete Category", role: .destructive) {
                if let deleteID { model.deleteCategory(id: deleteID) }
                deleteID = nil
                selectedID = nil
                name = ""
            }
        } message: { Text("Assigned apps will return to their automatic category. Installed apps are unaffected.") }
        .alert("Category Notice", isPresented: Binding(get: { model.operationError != nil }, set: { if !$0 { model.operationError = nil } })) {
            Button("OK", role: .cancel) { model.operationError = nil }
        } message: { Text(model.operationError ?? "") }
    }

    private func create() {
        let count = model.document.categories.count
        model.createCategory(named: name)
        if model.document.categories.count > count { name = ""; selectedID = nil }
    }
}
