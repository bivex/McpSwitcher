/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:28:28
 * Last Updated: 2025-12-27T20:55:55
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import SwiftUI
import AppKit
import SQLite
import Domain
import Infrastructure
import Application


struct ServerInfo: Identifiable {
    let id: String
    let name: String
    let isEnabled: Bool
}

struct ServerRow: SwiftUI.View {
    let server: ServerInfo
    let onToggle: (String, Bool) -> Void

    var body: some SwiftUI.View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 32, height: 32)

                Text(String(server.name.prefix(1)).uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Circle()
                        .fill(server.isEnabled ? Color.green : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)

                    Text(server.isEnabled ? "Enabled" : "Disabled")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { server.isEnabled },
                set: { onToggle(server.id, $0) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.clear)
    }
}

struct ServersView: SwiftUI.View {
    @StateObject private var viewModel: ServersViewModel

    init(appDelegate: AppDelegate) {
        _viewModel = StateObject(wrappedValue: ServersViewModel(appDelegate: appDelegate))
    }

    var body: some SwiftUI.View {
        VStack(spacing: 0) {
            // Title
            Text("Installed MCP Servers")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Loading state or servers list
            if viewModel.isLoading {
                Text("Loading servers...")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            } else if viewModel.servers.isEmpty {
                Text("No servers found")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.vertical, 40)
            } else {
                List(viewModel.servers) { server in
                    ServerRow(server: server, onToggle: viewModel.toggleServer)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }

            // Quit Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(minWidth: 380, maxWidth: 600)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .onAppear {
            viewModel.startRefreshing()
        }
        .onDisappear {
            viewModel.stopRefreshing()
        }
    }
}

@MainActor
class ServersViewModel: ObservableObject {
    @Published var servers: [ServerInfo] = []
    @Published var isLoading = true

    private var database: Database?
    private var isDBReady = false
    private var refreshTimer: Timer?
    private let dbQueue = DispatchQueue(label: "com.mcpswitcher.tray.db", attributes: .concurrent)
    private weak var appDelegate: AppDelegate?

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate

        // Check if database is already ready
        if appDelegate.isDBReady, let database = appDelegate.database {
            self.database = database
            self.isDBReady = true
            startRefreshing()
        } else {
            setupDatabaseObserver()
        }
    }

    private func setupDatabaseObserver() {
        // Check every 100ms if database is ready
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            Task { @MainActor in
                guard let appDelegate = self.appDelegate else {
                    timer.invalidate()
                    return
                }

                if appDelegate.isDBReady, let database = appDelegate.database {
                    self.database = database
                    self.isDBReady = true
                    timer.invalidate()

                    // Database is ready, start loading servers
                    self.startRefreshing()
                }
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    func startRefreshing() {
        guard isDBReady else {
            print("⚠ Cannot start refreshing: Database not ready")
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshServers()
            }
        }
        refreshServers()
    }

    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refreshServers() {
        guard isDBReady, let _ = database else {
            return
        }

        dbQueue.async(flags: .barrier) { [weak self] in
            Task { @MainActor in
                self?.loadServersFromDB()
            }
        }
    }

    private func loadServersFromDB() {
        guard let database = database else {
            return
        }

        do {
            let servers = try database.getAllServers()
            let serverInfos = servers.map { ServerInfo(id: $0.id, name: $0.name, isEnabled: $0.isEnabled) }

            DispatchQueue.main.async {
                self.servers = serverInfos.sorted { $0.name < $1.name }
                self.isLoading = false

                // Update status bar with enabled server count
                if let appDelegate = self.appDelegate {
                    let count = serverInfos.filter { $0.isEnabled }.count
                    appDelegate.statusItem.button?.title = count > 0 ? "\(count)" : ""
                }
            }
        } catch {
            print("✗ Load error: \(error)")
            // Show empty state on error
            DispatchQueue.main.async {
                self.servers = []
                self.isLoading = false
                if let appDelegate = self.appDelegate {
                    appDelegate.statusItem.button?.title = ""
                }
            }
        }
    }

    func toggleServer(_ serverId: String, _ isEnabled: Bool) {
        guard isDBReady, let appDelegate = appDelegate else {
            print("⚠ Cannot toggle server: Database not ready or no app delegate")
            return
        }

        Task { [weak self] in
            do {
                let repo = SQLiteServerRepository(database: appDelegate.database!)
                let syncUseCase = SyncWithMCPJSONUseCase(repository: repo)
                let toggleUseCase = ToggleServerUseCase(repository: repo, syncUseCase: syncUseCase)

                _ = try await toggleUseCase.setEnabled(serverId, enabled: isEnabled)

                // Refresh UI (already on MainActor)
                await MainActor.run {
                    self?.refreshServers()
                }
            } catch {
                print("✗ Toggle error: \(error)")
            }
        }
    }

}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var hostingController: NSHostingController<ServersView>!
    var database: Database?
    var isDBReady = false

    // Queue for DB operations
    let dbQueue = DispatchQueue(label: "com.mcpswitcher.tray.db", attributes: .concurrent)

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupPopover()
        setupDB()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }

    private func setupDB() {
        dbQueue.async(flags: .barrier) { [weak self] in
            do {
                self?.database = try Database()
                self?.isDBReady = true
                print("✓ Database ready: \(self?.database?.path ?? "unknown")")

                // Auto-import from Cursor MCP configuration
                self?.autoImportFromCursorMCP()
            } catch {
                print("✗ DB error: \(error)")
                self?.isDBReady = true // Mark as ready even on error to prevent hanging
            }
        }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: 44)
        statusItem.button?.image = createIcon()
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.target = self
        statusItem.button?.action = #selector(buttonClicked(_:))
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient

        hostingController = NSHostingController(rootView: ServersView(appDelegate: self))
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 400, height: 500)
    }

    private func createIcon() -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.systemOrange.setFill()
        NSBezierPath(ovalIn: NSRect(x: 1, y: 1, width: 14, height: 14)).fill()
        NSColor.white.setFill()
        NSBezierPath(ovalIn: NSRect(x: 6, y: 6, width: 4, height: 4)).fill()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    @objc private func buttonClicked(_ sender: NSStatusBarButton?) {
        let event = NSApplication.shared.currentEvent

        if event?.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover(sender)
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        menu.addItem(withTitle: "Open Servers", action: #selector(togglePopover(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Import JSON", action: #selector(importJSON), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.close()
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    @objc private func importJSON() {
        let panel = NSOpenPanel()
        panel.title = "Select MCP Servers JSON"
        panel.message = "Choose a JSON file with MCP server configurations"
        panel.allowsOtherFileTypes = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.treatsFilePackagesAsDirectories = false

        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.json]
        } else {
            panel.allowedFileTypes = ["json"]
        }

        let response = panel.runModal()
        if response == .OK, let url = panel.url {
            importServersFromFile(url.path)
        }
    }

    private func findMcpSwitcher() -> String? {
        let commonPaths = [
            ".build/debug/mcp-switcher",
            ".build/release/mcp-switcher",
            "/usr/local/bin/mcp-switcher",
            "/opt/homebrew/bin/mcp-switcher"
        ]

        for path in commonPaths {
            let expandedPath = (path as NSString).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                print("✓ Found mcp-switcher at: \(expandedPath)")
                return expandedPath
            }
        }

        if let bundlePath = Bundle.main.bundlePath as String? {
            let bundleDir = (bundlePath as NSString).deletingLastPathComponent
            let switcherPath = (bundleDir as NSString).appendingPathComponent("mcp-switcher")

            if FileManager.default.fileExists(atPath: switcherPath) {
                print("✓ Found mcp-switcher at: \(switcherPath)")
                return switcherPath
            }
        }

        let cwd = FileManager.default.currentDirectoryPath
        let cwdSwitcher = (cwd as NSString).appendingPathComponent(".build/debug/mcp-switcher")

        if FileManager.default.fileExists(atPath: cwdSwitcher) {
            print("✓ Found mcp-switcher at: \(cwdSwitcher)")
            return cwdSwitcher
        }

        return nil
    }

    private func importServersFromFile(_ filePath: String) {
        guard FileManager.default.fileExists(atPath: filePath) else {
            showAlert(title: "Error", message: "File not found: \(filePath)", style: .critical)
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            _ = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            showAlert(title: "Invalid JSON", message: error.localizedDescription, style: .critical)
            return
        }

        guard let switcherPath = findMcpSwitcher() else {
            showAlert(title: "Error", message: "Cannot find mcp-switcher executable", style: .critical)
            return
        }

        executeImportCommand(switcherPath: switcherPath, jsonPath: filePath)
    }

    private func executeImportCommand(switcherPath: String, jsonPath: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: switcherPath)
            task.arguments = ["import", jsonPath, "--enable-all"]

            let outPipe = Pipe()
            let errPipe = Pipe()
            task.standardOutput = outPipe
            task.standardError = errPipe

            do {
                try task.run()
                task.waitUntilExit()

                let exitCode = task.terminationStatus
                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

                let outString = String(data: outData, encoding: .utf8) ?? ""
                let errString = String(data: errData, encoding: .utf8) ?? ""

                DispatchQueue.main.async {
                    if exitCode == 0 {
                        self.showAlert(
                            title: "✓ Import Successful",
                            message: "Servers imported and enabled!",
                            style: .informational
                        )
                        // Refresh will be handled by the SwiftUI view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.togglePopover(nil)
                        }
                    } else {
                        let errorMsg = errString.isEmpty ? outString : errString
                        self.showAlert(
                            title: "Import Failed",
                            message: errorMsg.isEmpty ? "Unknown error" : errorMsg,
                            style: .critical
                        )
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Error",
                        message: error.localizedDescription,
                        style: .critical
                    )
                }
            }
        }
    }

    private func showAlert(title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func autoImportFromCursorMCP() {
        Task { [weak self] in
            guard let self = self else { return }
            guard let database = self.database else {
                print("⚠ Auto-import failed: Database not ready")
                return
            }

            do {
                let repo = SQLiteServerRepository(database: database)
                let useCase = ImportFromJSONUseCase(repository: repo)

                let result = try await useCase.autoImportFromCursorMCP()

                if result.added > 0 || result.updated > 0 {
                    print("✓ Auto-imported MCP servers: +\(result.added) updated: \(result.updated)")
                }

                if !result.errors.isEmpty {
                    print("⚠ Auto-import warnings:")
                    for error in result.errors {
                        print("  - \(error)")
                    }
                }
            } catch {
                print("⚠ Auto-import failed: \(error)")
            }
        }
    }
}

let appDelegate = AppDelegate()

@main
struct McpTrayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We don't need a main window for a tray app, but SwiftUI requires at least one scene
        // We'll keep this minimal and hidden
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 0, height: 0)
    }
}
