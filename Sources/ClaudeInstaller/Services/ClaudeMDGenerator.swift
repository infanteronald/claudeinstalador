import Foundation

final class ClaudeMDGenerator: Sendable {

    func generateAndWrite(skillLevel: SkillLevel, projectPath: String) async throws {
        let content = generateContent(skillLevel: skillLevel)
        let claudeMDPath = "\(FileSystemHelper.expandPath(projectPath))/CLAUDE.md"

        do {
            try FileSystemHelper.createDirectory(projectPath)
            try FileSystemHelper.writeFile(claudeMDPath, content: content)
        } catch {
            throw InstallerError.claudeMDWriteFailed(error.localizedDescription)
        }
    }

    func generateContent(skillLevel: SkillLevel) -> String {
        switch skillLevel {
        case .beginner:
            return beginnerTemplate
        case .intermediate:
            return intermediateTemplate
        case .advanced:
            return advancedTemplate
        case .expert:
            return expertTemplate
        }
    }

    private var beginnerTemplate: String {
        """
        # CLAUDE.md - Project Rules

        ## Communication
        - Always explain what you're about to do BEFORE doing it
        - Use simple, non-technical language when possible
        - After making changes, explain what was changed and why
        - If something could go wrong, warn me first
        - Always ask for confirmation before deleting files or making major changes

        ## Safety Rules
        - NEVER delete files without explicit permission
        - NEVER run destructive commands (rm -rf, git reset --hard, etc.)
        - Always create backups before modifying important files
        - If unsure about something, ask rather than guess
        - Keep explanations clear and step-by-step

        ## Code Style
        - Add comments explaining what each section does
        - Use descriptive variable and function names
        - Keep code simple and readable over clever
        - Follow existing patterns in the project

        ## Workflow
        - Work on one task at a time
        - Show progress as you work
        - Summarize what was accomplished at the end
        """
    }

    private var intermediateTemplate: String {
        """
        # CLAUDE.md - Project Rules

        ## Communication
        - Explain significant changes before making them
        - Be concise but clear in explanations
        - Ask for confirmation on destructive operations

        ## Safety
        - No destructive commands without permission
        - Prefer safe alternatives (git stash over reset --hard)
        - Validate inputs and handle errors gracefully

        ## Code Style
        - Follow existing project conventions
        - Add comments for complex logic only
        - Use meaningful names for variables and functions
        - Keep functions focused and small

        ## Workflow
        - Plan approach before implementing
        - Run tests after making changes
        - Commit logically related changes together
        """
    }

    private var advancedTemplate: String {
        """
        # CLAUDE.md - Project Rules

        ## Rules
        - Follow existing code style and conventions
        - Ask before destructive operations
        - Run tests after changes
        - Keep commits atomic and well-described
        - Prefer composition over inheritance
        - Handle errors at appropriate boundaries
        """
    }

    private var expertTemplate: String {
        """
        # CLAUDE.md

        - Follow existing patterns
        - Confirm before destructive ops
        - Run tests
        - Atomic commits
        """
    }
}
