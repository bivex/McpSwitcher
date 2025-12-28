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

struct SkillInfo: Identifiable {
    let id: String
    let title: String
    let description: String?
    let category: String?
    let difficulty: String?
    let stars: Double?
    let starCount: Int?
    let tags: [String]
    let author: String?
    let url: String?
    let githubUrl: String?

    var displayStars: String {
        if let stars = stars {
            return String(format: "%.1f", stars)
        }
        return "N/A"
    }

    var displayStarCount: String {
        if let starCount = starCount {
            return "\(starCount)"
        }
        return ""
    }
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

struct SkillRow: SwiftUI.View {
    let skill: SkillInfo
    let onCopy: (SkillInfo) -> Void
    let onOpenGitHub: (SkillInfo) -> Void
    let onCopyRawGitHub: (SkillInfo) -> Void
    
    private var isParsedAndCached: Bool {
        let cacheKey = "parsed_skill_\(skill.id)"
        return UserDefaults.standard.data(forKey: cacheKey) != nil
    }

    var body: some SwiftUI.View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and action buttons
            HStack {
                Text(skill.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Cached indicator
                if isParsedAndCached {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                        .help("Permanently parsed and cached")
                }

                Spacer()

                // GitHub buttons (only if GitHub URL exists)
                if skill.githubUrl != nil {
                    Button(action: { onOpenGitHub(skill) }) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .help("Open GitHub link")

                    Button(action: { onCopyRawGitHub(skill) }) {
                        HStack(spacing: 2) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 12))
                            if isParsedAndCached {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 8))
                            }
                        }
                        .foregroundColor(.purple)
                    }
                    .buttonStyle(.plain)
                    .help(isParsedAndCached ? "Copy cached parsed content (permanently saved)" : "Parse and copy raw GitHub content")
                }

                // Copy button
                Button(action: { onCopy(skill) }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Copy skill info to clipboard")
            }

            // Description
            if let description = skill.description {
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            // Metadata row
            HStack(spacing: 12) {
                if let category = skill.category {
                    Label(category, systemImage: "tag")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }

                if let difficulty = skill.difficulty {
                    Label(difficulty.capitalized, systemImage: "chart.bar")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }

                if skill.stars != nil {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("\(skill.displayStars)")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        if !skill.displayStarCount.isEmpty {
                            Text("(\(skill.displayStarCount))")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            // Tags
            if !skill.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(skill.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9))
                                .foregroundColor(.blue.opacity(0.8))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        if skill.tags.count > 3 {
                            Text("+\(skill.tags.count - 3)")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.clear)
    }
}

struct SkillsView: SwiftUI.View {
    @StateObject private var viewModel = SkillsViewModel()

    init() {
        print("🎨 SkillsView initialized")
    }

    var body: some SwiftUI.View {
        VStack(spacing: 0) {
            // Header with API key input
            VStack(spacing: 12) {
                Text("Skills Search")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    SecureField("SkillsMP API Key", text: $viewModel.apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .frame(height: 28)

                    Button(action: viewModel.saveApiKey) {
                        Image(systemName: "key")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.apiKey.isEmpty)
                    .help("Save API key")
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)

            // Search controls
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("Search skills...", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .frame(height: 28)

                    Button(action: viewModel.searchKeywords) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.searchQuery.isEmpty || viewModel.apiKey.isEmpty)
                    .help("Keyword search")

                    Button(action: viewModel.searchAI) {
                        Image(systemName: "brain")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.searchQuery.isEmpty || viewModel.apiKey.isEmpty)
                    .help("AI semantic search")
                }

                // Search type toggle
                VStack(spacing: 4) {
                    Picker("", selection: $viewModel.searchType) {
                        Text("Keywords").tag(SkillsViewModel.SearchType.keywords)
                        Text("AI Search").tag(SkillsViewModel.SearchType.ai)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .font(.system(size: 11))

                    if viewModel.searchType == .ai {
                        Text("AI search shows all results at once")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }

                // Sorting controls (only for keyword search)
                if viewModel.searchType == .keywords {
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Sort by:")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            Picker("", selection: $viewModel.sortBy) {
                                Text("Default").tag(String?.none)
                                Text("Stars").tag(String?.some("stars"))
                                Text("Recent").tag(String?.some("recent"))
                            }
                            .pickerStyle(.segmented)
                            .font(.system(size: 10))
                            .frame(width: 180)
                        }
                    }
                }

                // Loading indicator
                if viewModel.isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Searching...")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)

            // Results
            if viewModel.errorMessage.isEmpty == false {
                Text(viewModel.errorMessage)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            } else if viewModel.skills.isEmpty && !viewModel.isSearching {
                if viewModel.hasSearched {
                    Text("No skills found")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    Text("Enter a search query above")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.skills) { skill in
                            SkillRow(skill: skill, onCopy: viewModel.copySkillToClipboard, onOpenGitHub: viewModel.openGitHubLink, onCopyRawGitHub: viewModel.copyRawGitHubContent)
                                .background(Color.white.opacity(0.02))

                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }

            // Pagination Controls
            if viewModel.hasSearched && viewModel.totalPages > 1 {
                VStack(spacing: 8) {
                    HStack {
                        Button(action: viewModel.goToPrevPage) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.hasPrevPage)

                        Text("\(viewModel.currentPage) of \(viewModel.totalPages)")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .frame(minWidth: 60)

                        Button(action: viewModel.goToNextPage) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.hasNextPage)
                    }

                    if viewModel.totalPages <= 10 {
                        // Show page number buttons for small page counts
                        HStack(spacing: 4) {
                            ForEach(1...viewModel.totalPages, id: \.self) { page in
                                Button("\(page)") {
                                    viewModel.goToPage(page)
                                }
                                .font(.system(size: 10))
                                .buttonStyle(.bordered)
                                .background(viewModel.currentPage == page ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Capsule())
                                .frame(width: 24, height: 20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Footer
            HStack {
                if viewModel.skills.count > 0 {
                    Text("\(viewModel.totalResults) skills total, showing page \(viewModel.currentPage)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                // Show parsed cache count
                let cachedCount = viewModel.getParsedSkillsCount()
                if cachedCount > 0 {
                    Text("• \(cachedCount) parsed 💾")
                        .font(.system(size: 10))
                        .foregroundColor(.purple)
                        .help("Number of permanently parsed skills in cache")
                }
                
                Spacer()
                
                // Clear cache button
                if viewModel.getParsedSkillsCount() > 0 {
                    Button("Clear Cache") {
                        viewModel.clearParsedSkillsCache()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                }
                
                Button("Clear") {
                    viewModel.clearResults()
                }
                .font(.system(size: 11))
                .buttonStyle(.bordered)
                .disabled(viewModel.skills.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(minWidth: 450, maxWidth: 600)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .onAppear {
            viewModel.loadApiKey()
            // Test clipboard functionality after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("🧪 Testing clipboard from SkillsView...")
                viewModel.testClipboard()
            }
        }
    }
}

@MainActor
class SkillsViewModel: ObservableObject {
    enum SearchType {
        case keywords
        case ai
    }

    @Published var apiKey = ""
    @Published var searchQuery = ""
    @Published var searchType: SearchType = .keywords {
        didSet {
            // Reset to page 1 when switching search types
            if searchType != oldValue {
                currentPage = 1
            }
        }
    }
    @Published var sortBy: String? = nil
    @Published var skills: [SkillInfo] = []
    @Published var isSearching = false
    @Published var errorMessage = ""
    @Published var hasSearched = false

    // Pagination state
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalResults = 0
    @Published var hasNextPage = false
    @Published var hasPrevPage = false
    private let resultsPerPage = 20

    private var apiService: SkillsAPIService?
    private var clipboardService: ClipboardService?

    init() {
        setupServices()
    }

    private func setupServices() {
        if !apiKey.isEmpty {
            apiService = SkillsMPAPIService(apiKey: apiKey)
            print("🔧 API service initialized with key")
        } else {
            print("🔧 API service not initialized (no key)")
        }
        clipboardService = SystemClipboardService()
        print("🔧 Clipboard service initialized")
    }

    func loadApiKey() {
        if let key = UserDefaults.standard.string(forKey: "skillsmp_api_key") {
            apiKey = key
            setupServices()
        }
    }

    func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: "skillsmp_api_key")
        setupServices()
    }

    func searchKeywords() {
        guard !searchQuery.isEmpty, !apiKey.isEmpty else { return }
        currentPage = 1 // Reset to first page for new search
        performSearch(isAI: false)
    }

    func searchAI() {
        guard !searchQuery.isEmpty, !apiKey.isEmpty else { return }
        currentPage = 1 // Reset to first page for new search
        performSearch(isAI: true)
    }

    func goToNextPage() {
        guard hasNextPage else { return }
        currentPage += 1
        performSearch(isAI: searchType == .ai)
    }

    func goToPrevPage() {
        guard hasPrevPage else { return }
        currentPage -= 1
        performSearch(isAI: searchType == .ai)
    }

    func goToPage(_ page: Int) {
        guard page >= 1 && page <= totalPages else { return }
        currentPage = page
        performSearch(isAI: searchType == .ai)
    }

    private func performSearch(isAI: Bool) {
        guard let apiService = apiService else {
            errorMessage = "API key not configured"
            return
        }

        isSearching = true
        errorMessage = ""
        hasSearched = true

        Task {
            do {
                let result: SkillSearchResult
                if isAI {
                    // AI search doesn't support pagination in current API
                    result = try await apiService.searchSkillsAI(query: searchQuery)
                } else {
                    result = try await apiService.searchSkills(
                        query: searchQuery,
                        page: currentPage,
                        limit: resultsPerPage,
                        sortBy: sortBy
                    )
                }

                await MainActor.run {
                    self.skills = result.skills.map { skill in
                        SkillInfo(
                            id: skill.id,
                            title: skill.title,
                            description: skill.description,
                            category: skill.category,
                            difficulty: skill.difficulty,
                            stars: skill.stars,
                            starCount: skill.starCount,
                            tags: skill.tags,
                            author: skill.author,
                            url: skill.url,
                            githubUrl: skill.githubUrl
                        )
                    }

                    // Update pagination state
                    self.totalResults = result.totalCount
                    if isAI {
                        // AI search returns all results at once
                        self.totalPages = 1
                        self.hasNextPage = false
                        self.hasPrevPage = false
                    } else {
                        self.totalPages = Int(ceil(Double(result.totalCount) / Double(self.resultsPerPage)))
                        self.hasNextPage = result.hasMore
                        self.hasPrevPage = self.currentPage > 1
                    }

                    self.isSearching = false
                }
            } catch let error as SkillsAPIError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.skills = []
                    self.isSearching = false
                    // Reset pagination on error
                    self.totalPages = 1
                    self.hasNextPage = false
                    self.hasPrevPage = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.skills = []
                    self.isSearching = false
                    // Reset pagination on error
                    self.totalPages = 1
                    self.hasNextPage = false
                    self.hasPrevPage = false
                }
            }
        }
    }

    func copySkillToClipboard(skill: SkillInfo) {
        guard let clipboardService = clipboardService else {
            print("❌ Clipboard service not initialized")
            return
        }

        // Convert SkillInfo back to Skill for clipboard formatting
        let skillModel = Skill(
            id: skill.id,
            title: skill.title,
            description: skill.description,
            category: skill.category,
            difficulty: skill.difficulty,
            duration: nil,
            stars: skill.stars,
            starCount: skill.starCount,
            tags: skill.tags,
            url: skill.url,
            githubUrl: skill.githubUrl,
            author: skill.author,
            updatedAt: nil
        )

        print("🔍 Formatting skill for clipboard: \(skill.title)")
        let formattedText = skillModel.formatForClipboard()
        print("📝 Formatted text length: \(formattedText.count) characters")

        let useCase = CopySkillToClipboardUseCase(clipboardService: clipboardService)
        let success = useCase.execute(skill: skillModel)

        if success {
            print("✓ Successfully copied \(skill.title) to clipboard")
        } else {
            print("❌ Failed to copy \(skill.title) to clipboard")
        }
    }

    func openGitHubLink(skill: SkillInfo) {
        guard let githubUrl = skill.githubUrl,
              let url = URL(string: githubUrl) else {
            print("⚠ No GitHub URL available for skill: \(skill.title)")
            return
        }

        #if os(macOS)
        NSWorkspace.shared.open(url)
        print("✓ Opened GitHub link for: \(skill.title)")
        #else
        print("⚠ GitHub link opening not supported on this platform: \(url)")
        #endif
    }

    func copyRawGitHubContent(skill: SkillInfo) {
        guard let githubUrl = skill.githubUrl else {
            print("⚠ No GitHub URL available for skill: \(skill.title)")
            return
        }

        print("═══════════════════════════════════════════════════════════")
        print("🟣 PURPLE BUTTON CLICKED - ПРЯМОЕ КОПИРОВАНИЕ С GITHUB")
        print("═══════════════════════════════════════════════════════════")
        print("🎯 Skill: \(skill.title)")
        print("🔗 GitHub URL: \(githubUrl)")
        print("📡 Fetching directly from GitHub...")

        Task {
            do {
                let rawContent = try await fetchRawGitHubContent(from: githubUrl)
                print("✅ Successfully fetched \(rawContent.count) characters from GitHub!")
                print("📄 First 100 chars: \(String(rawContent.prefix(100)))...")
                
                await MainActor.run {
                    // Parse and copy to clipboard - THIS IS THE KEY ACTION!
                    copyRawContentToClipboard(rawContent, skillTitle: skill.title, skill: skill)
                    
                    // Save parsed content permanently
                    saveParsedSkillToCache(skill: skill, rawContent: rawContent)
                    
                    print("═══════════════════════════════════════════════════════════")
                    print("✅ ГОТОВО! СКОПИРОВАНО В БУФЕР ОБМЕНА!")
                    print("📋 Теперь можно вставить (Cmd+V)")
                    print("═══════════════════════════════════════════════════════════")
                }
            } catch {
                await MainActor.run {
                    print("❌ Failed to fetch from GitHub: \(error.localizedDescription)")
                    print("🔄 Trying fallback: copying skill metadata...")
                    copySkillInfoAsFallback(skill)
                }
            }
        }
    }
    
    private func copySkillInfoAsFallback(_ skill: SkillInfo) {
        print("🔄 Using fallback: copying skill info instead of raw content")
        copySkillToClipboard(skill: skill)
    }
    
    private func saveParsedSkillToCache(skill: SkillInfo, rawContent: String) {
        // Save to UserDefaults for permanent storage
        let cacheKey = "parsed_skill_\(skill.id)"
        let metadata: [String: Any] = [
            "id": skill.id,
            "title": skill.title,
            "githubUrl": skill.githubUrl ?? "",
            "parsedAt": Date().timeIntervalSince1970,
            "rawContent": rawContent
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: metadata) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            print("💾 Permanently saved parsed skill to cache: \(skill.title)")
            
            // Also save to a list of all parsed skills
            var parsedSkillIds = UserDefaults.standard.stringArray(forKey: "all_parsed_skills") ?? []
            if !parsedSkillIds.contains(skill.id) {
                parsedSkillIds.append(skill.id)
                UserDefaults.standard.set(parsedSkillIds, forKey: "all_parsed_skills")
            }
        }
    }

    private func fetchRawGitHubContent(from githubUrl: String) async throws -> String {
        // Convert GitHub tree URL to multiple possible raw URLs and try them
        let pattern = #"^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: githubUrl, options: [], range: NSRange(githubUrl.startIndex..., in: githubUrl)),
              match.numberOfRanges >= 5 else {
            print("❌ Failed to parse GitHub URL: \(githubUrl)")
            throw URLError(.badURL)
        }

        let owner = (githubUrl as NSString).substring(with: match.range(at: 1))
        let repo = (githubUrl as NSString).substring(with: match.range(at: 2))
        let branch = (githubUrl as NSString).substring(with: match.range(at: 3))
        let path = (githubUrl as NSString).substring(with: match.range(at: 4))

        print("🔗 Parsed GitHub URL: owner=\(owner), repo=\(repo), branch=\(branch), path=\(path)")

        // Try different possible raw URLs for Claude skills
        let possibleUrls = [
            // Direct file (if path ends with .md)
            path.hasSuffix(".md") ? "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)" : nil,
            // SKILL.md in the directory (uppercase - PyTorch convention)
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/SKILL.md",
            // skill.md in the directory (lowercase)
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/skill.md",
            // Skill.md (capitalized)
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/Skill.md",
            // README.md in the directory
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/README.md",
            // readme.md (lowercase)
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/readme.md",
            // File with same name as directory
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(path)/\(path.components(separatedBy: "/").last ?? "skill").md",
            // Try without the .claude/skills/ part if it exists
            path.hasPrefix(".claude/skills/") ?
                "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/SKILL.md" : nil,
            path.hasPrefix(".claude/skills/") ?
                "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/skill.md" : nil,
            // Common Claude skill locations
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/.claude/skills/SKILL.md",
            "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/.claude/skills/skill.md"
        ].compactMap { $0 }

        for urlString in possibleUrls {
            print("🔍 Trying to fetch: \(urlString)")
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL: \(urlString)")
                continue
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP response for: \(urlString)")
                    continue
                }

                if (200...299).contains(httpResponse.statusCode) {
                    guard let content = String(data: data, encoding: .utf8), !content.isEmpty else {
                        print("❌ Empty or invalid content from: \(urlString)")
                        continue
                    }

                    print("✅ Successfully fetched \(content.count) characters from: \(urlString)")
                    return content
                } else {
                    print("❌ HTTP \(httpResponse.statusCode) for: \(urlString)")
                }
            } catch {
                print("❌ Network error for \(urlString): \(error.localizedDescription)")
            }
        }

        print("❌ All raw URL attempts failed for GitHub URL: \(githubUrl)")
        throw URLError(.fileDoesNotExist)
    }


    private func copyRawContentToClipboard(_ content: String, skillTitle: String, skill: SkillInfo) {
        guard let clipboardService = clipboardService else {
            print("❌ Clipboard service not available")
            return
        }

        print("🎨 Formatting GitHub content for clipboard...")
        print("📝 Raw content length: \(content.count) characters")
        
        // Parse and format the raw content with enhanced metadata
        let formattedContent = parseAndFormatSkillContent(
            content, 
            skillTitle: skillTitle,
            skillId: skill.id,
            githubUrl: skill.githubUrl,
            description: skill.description,
            tags: skill.tags
        )

        print("📝 Formatted content length: \(formattedContent.count) characters")
        print("📋 Copying to system clipboard...")
        
        let success = clipboardService.copyToClipboard(formattedContent)
        if success {
            print("")
            print("✅✅✅ SUCCESS! СКОПИРОВАНО В БУФЕР ОБМЕНА! ✅✅✅")
            print("")
            print("📊 Total characters: \(formattedContent.count)")
            print("🎯 Skill: \(skillTitle)")
            print("💾 Saved to permanent cache")
            print("📋 Ready to paste with Cmd+V")
            print("")
            
            // Show first 150 chars as preview
            let lines = formattedContent.components(separatedBy: "\n")
            print("📄 Preview (first 5 lines):")
            for (i, line) in lines.prefix(5).enumerated() {
                print("   \(i+1). \(line)")
            }
            print("")
        } else {
            print("❌ FAILED to copy to clipboard - trying fallback method...")
            // Try fallback with pbcopy if available
            let tempFile = "/tmp/skill_content_\(UUID().uuidString).txt"
            if let data = formattedContent.data(using: .utf8) {
                do {
                    try data.write(to: URL(fileURLWithPath: tempFile))
                    let task = Process()
                    task.executableURL = URL(fileURLWithPath: "/usr/bin/pbcopy")
                    task.standardInput = FileHandle(forReadingAtPath: tempFile)
                    try task.run()
                    task.waitUntilExit()
                    print("✅ Fallback successful - copied via pbcopy")
                } catch {
                    print("❌ Fallback also failed: \(error)")
                }
            }
        }
    }

    private func parseAndFormatSkillContent(
        _ content: String, 
        skillTitle: String,
        skillId: String,
        githubUrl: String?,
        description: String?,
        tags: [String]
    ) -> String {
        print("🔍 Copying raw content from GitHub: \(skillTitle)")
        
        // Return the raw content as-is from GitHub - no parsing, no formatting
        let result = content

        // Clean finish - no extra footer
        print("✅ Parsing complete: \(result.count) characters")
        return result
    }

    func clearResults() {
        skills = []
        errorMessage = ""
        hasSearched = false
        currentPage = 1
        totalPages = 1
        totalResults = 0
        hasNextPage = false
        hasPrevPage = false
        sortBy = nil
    }
    
    func getParsedSkillsCount() -> Int {
        let parsedSkillIds = UserDefaults.standard.stringArray(forKey: "all_parsed_skills") ?? []
        return parsedSkillIds.count
    }
    
    func loadParsedSkillFromCache(skillId: String) -> String? {
        let cacheKey = "parsed_skill_\(skillId)"
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let metadata = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawContent = metadata["rawContent"] as? String else {
            return nil
        }
        return rawContent
    }
    
    func clearParsedSkillsCache() {
        let parsedSkillIds = UserDefaults.standard.stringArray(forKey: "all_parsed_skills") ?? []
        for skillId in parsedSkillIds {
            UserDefaults.standard.removeObject(forKey: "parsed_skill_\(skillId)")
        }
        UserDefaults.standard.removeObject(forKey: "all_parsed_skills")
        print("🗑️ Cleared all parsed skills cache (\(parsedSkillIds.count) items)")
    }

    func testClipboard() {
        guard let clipboardService = clipboardService else {
            print("❌ Clipboard service not initialized in test")
            return
        }

        let testText = "Test clipboard from tray app at \(Date())"
        print("📝 Testing clipboard with: \(testText)")

        let success = clipboardService.copyToClipboard(testText)
        if success {
            print("✅ Tray app clipboard test successful!")
            
            // Show info about parsed skills cache
            let count = getParsedSkillsCount()
            print("💾 Parsed skills in permanent cache: \(count)")
        } else {
            print("❌ Tray app clipboard test failed!")
        }
    }
}

struct MainPopoverView: SwiftUI.View {
    @State private var selectedTab = 0
    private let appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    var body: some SwiftUI.View {
        TabView(selection: $selectedTab) {
            ServerManagementView(appDelegate: appDelegate)
                .tabItem {
                    Label("Servers", systemImage: "server.rack")
                }
                .tag(0)

            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "book")
                }
                .tag(1)
        }
        .frame(minWidth: 500, minHeight: 600)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
    }
}

struct ServerManagementView: SwiftUI.View {
    @StateObject private var viewModel: ServersViewModel

    init(appDelegate: AppDelegate) {
        _viewModel = StateObject(wrappedValue: ServersViewModel(appDelegate: appDelegate))
    }

    var body: some SwiftUI.View {
        VStack(spacing: 0) {
            // Title
            Text("MCP Servers")
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
    var hostingController: NSHostingController<MainPopoverView>!
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

        hostingController = NSHostingController(rootView: MainPopoverView(appDelegate: self))
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 550, height: 650)
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
        menu.addItem(withTitle: "Test Clipboard", action: #selector(testClipboard), keyEquivalent: "")
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

    @objc private func testClipboard() {
        print("🧪 Manual clipboard test triggered from menu")
        // Test clipboard directly without creating a view model
        let clipboardService = SystemClipboardService()
        let testText = "Test clipboard from menu at \(Date())"
        print("📝 Testing clipboard with: \(testText)")

        let success = clipboardService.copyToClipboard(testText)
        if success {
            print("✅ Menu clipboard test successful!")
        } else {
            print("❌ Menu clipboard test failed!")
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
